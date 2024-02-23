#include <algorithm>
#include <assert.h>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cstdint>
#include <cstring>
#include <string>
#include <stdexcept>
#include "neuron_api_headers.h"
#include "neuron_dllimports.h"
#include "nrnmatlab.h"

// Declare mexPrintf
// We cannot include mex.h with clib, because during build will give
// "error Using MATLAB Data API with C Matrix API is not supported."
extern "C" int mexPrintf(const char *message, ...);

// Declare mexEvalString
extern "C" int mexEvalString(const char *command);

// Define ivocmain_session input.
static const char* argv[] = {"nrn_test", "-nogui", "-nopython", NULL};

// Keep track of whether NEURON session is already initialized.
bool initialized = false;

// Print to MATLAB command window.
int mlprint(int stream, char* msg) {
    // stream = 1 for stdout; otherwise stderr
    if (stream == 1) {
        mexPrintf(msg);
    } else {
        // We could add something to error messages here.
        mexPrintf(msg);
    }
    return 0;
}

// Initialize NEURON session.
void initialize(){

    if (!initialized) {

        // Redirect stdout/sterr output to MATLAB.
        nrn_is_python_extension = 1;
        nrnpy_set_pr_etal(mlprint, NULL);
        nrn_is_python_extension = 0;
    
        // Initialize NEURON session.
        if (nrnmpi_stubs) {
            nrnmpi_stubs();
        }
        nrn_main_launch = 0;
        nrn_nobanner_ = 0; // 0 to write banner (to stderr), 1 to hide banner.
        ivocmain_session(3, argv, NULL, 0);

        initialized = true;
    }

}
bool isinitialized() {
    return initialized;
}

// Increase try/catch nest depth after catching an error.
int increase_try_catch_nest_depth() {
    nrn_try_catch_nest_depth++;
    return nrn_try_catch_nest_depth;
}
int decrease_try_catch_nest_depth() {
    nrn_try_catch_nest_depth--;
    return nrn_try_catch_nest_depth;
}

hoc_Item* get_section_list() {
    return section_list;
}
hoc_Item* get_obj_u_this_pointer(Object* ob){
    return (hoc_Item*) ob->u.this_pointer;
}
Section* get_hoc_item_element_sec(hoc_Item* hoc_item) {
    return hoc_item->element.sec;
}
ShapePlotInterface* get_plotshape_interface(Object* ps) {
    ShapePlotInterface* spi;
    hoc_Item** my_section_list;
    spi = ((ShapePlotInterface*) ps->u.this_pointer);
    return spi;
}

// Return all functions/methods/attributes as a string with separators ";"
// between methods, and ":" between method name and method type.
std::string str_symbol_table(Symlist* table) {
    std::string tabstr, new_tabstr;
    for (Symbol* sp = table->first; sp != NULL; sp = sp->next) {
        new_tabstr = std::string(sp->name) + ":" + 
                     std::to_string(sp->type) + "-" + 
                     std::to_string(sp->subtype) + ";";
        tabstr = tabstr + new_tabstr;
    }
    return tabstr;
}

// Return all top-level functions.
std::string get_nrn_functions() {
    return str_symbol_table(hoc_built_in_symlist) + 
        str_symbol_table(hoc_top_level_symlist);
}

// Get pointer to top-level symbol.
NrnRef* ref(const char* tlsym){
    auto sym = hoc_lookup(tlsym);
    NrnRef* ref = new NrnRef(sym->u.pval);
    return ref;
}

// Get pointer from nrn_rangepointer.
NrnRef* range_ref(Section* sec, const char* sym, double val){
    NrnRef* ref = new NrnRef(nrn_rangepointer(sec, hoc_lookup(sym), val));
    return ref;
}

// Return all object methods & attributes.
std::string get_class_methods(const char* class_name) {
    auto sym = hoc_lookup(class_name);
    Symlist* table = sym->u.ctemplate->symtable;
    return str_symbol_table(table);
}

// Get Vector size.
int get_vector_capacity(Object* vec){
    return vector_capacity(vec->u.this_pointer);
}

// Get Vector data.
const double* get_vector_vec(Object* vec, int len){
    return vector_vec(vec->u.this_pointer);
}

// Get Vector ref.
NrnRef* get_vector_ref(Object* vec, size_t len){
    NrnRef* ref = new NrnRef(vector_vec(vec->u.this_pointer), len);
    return ref;
}

// Pushing/popping objects onto/from the stack.
void matlab_hoc_pushpx(NrnRef* nrnref) {
    hoc_pushpx(nrnref->ref);
}
void matlab_hoc_pushstr(const char* strin) {
    // TODO: By using a static char* here, we can only ever have one string
    // on the stack, which is enough for our current example scripts. 
    // However, adding a second string changes the first one. Maybe this 
    // can be fixed in the future by using something like:
    //      char** ts = hoc_temp_charptr();
    //      *ts = strin.c_str();
    //      hoc_pushstr(ts);
    // However, then we need to keep track of ts and free it later to
    // prevent a memory leak. Moreover, hoc_temp_charptr can only hold 128 
    // items.
    static char* cptr = new char[strlen(strin)];
    strcpy(cptr, strin);
    hoc_pushstr(&cptr);
}
std::string matlab_hoc_strpop(void) {
    std::string str_out = std::string(*hoc_strpop());
    return str_out;
}
Object* matlab_hoc_objpop(void) {
    Object** obptr = hoc_objpop();
    Object* ob = *obptr;
    ob->refcount++;
    hoc_tobj_unref(obptr);
    return ob;
}

// Make and return a new section.
Section* new_section(const char* name) {
    Symbol* symbol = new Symbol;
    auto pitm = new hoc_Item*;
    char* name_ptr = new char[strlen(name)];
    strcpy(name_ptr, name);
    symbol->name = name_ptr;
    symbol->type = 1;
    symbol->type = 308;
    symbol->arayinfo = 0;    
    hoc_install_object_data_index(symbol);
    hoc_top_level_data[symbol->u.oboff].psecitm = pitm;
    new_sections(nullptr, symbol, pitm, 1);
    return (*pitm)->element.sec;
}

// Set/get object property.
void set_pp_property(Object* pp, const char* name, double value, int element) {
    int index = hoc_table_lookup(name, pp->ctemplate->symtable)->u.rng.index;
    ob2pntproc_0(pp)->prop->param[index + element] = value;
}
double get_pp_property(Object* pp, const char* name, int element) {
    int index = hoc_table_lookup(name, pp->ctemplate->symtable)->u.rng.index;
    return ob2pntproc_0(pp)->prop->param[index + element];
}
NrnRef* ref_pp_property(Object* pp, const char* name, int element) {
    int index = hoc_table_lookup(name, pp->ctemplate->symtable)->u.rng.index;
    NrnRef* ref = new NrnRef(ob2pntproc_0(pp)->prop->param + index + element);
    return ref;
}
void set_steered_property(Object* obj, const char* name, double value) {
    auto sym = hoc_table_lookup(name, obj->ctemplate->symtable);
    hoc_pushs(sym);
    // put the pointer for the memory location on the stack 
    obj->ctemplate->steer(obj->u.this_pointer);
    double* prop_p = hoc_pxpop();
    *prop_p = value;
}
double get_steered_property(Object* obj, const char* name) {
    auto sym = hoc_table_lookup(name, obj->ctemplate->symtable);
    hoc_pushs(sym);
    // put the pointer for the memory location on the stack 
    obj->ctemplate->steer(obj->u.this_pointer);
    return *hoc_pxpop();
}


// Set Section dparams.
double get_dparam(Section* sec, int ind) {
    return sec->prop->dparam[ind].val;
}
void set_dparam(Section* sec, int ind, double value) {
    sec->prop->dparam[ind].val = value;
}
void set_diam_changed(int value) {
    diam_changed = value;
};

void set_node_diam(Node* node, double diam) {
    // TODO: this is fine if no 3D points; does it work if there are 3D points?
    for (auto prop = node->prop; prop; prop=prop->next) {
        if (prop->_type == MORPHOLOGY) {
            prop->param[0] = diam;
            diam_changed = 1;
            node->sec->recalc_area_ = 1;
            break;
        }
    }
}

// Special case: set/get n.secondorder.
void set_secondorder(int val) {
    secondorder = val;
}
int get_secondorder(void) {
    return secondorder;
}

// adapted from ocjump.cpp
SavedState::SavedState() {
    // not complete but it is good for expressions and it can be improved
    oc_save_hoc_oop(&(this->o1), &(this->o2), &(this->o4), &(this->o5));
    oc_save_code(&(this->c1), &(this->c2), this->c3, &(this->c4), &(this->c5), 
                 &(this->c6), &(this->c7), &(this->c8), this->c9, &(this->c10), 
                 &(this->c11), &(this->c12));
    oc_save_input_info(&(this->i1), &(this->i2), &(this->i3), &(this->i4));
    oc_save_cabcode(&(this->cc1), &(this->cc2));
}

void SavedState::restore() {
    oc_restore_hoc_oop(&(this->o1), &(this->o2), &(this->o4), &(this->o5));
    oc_restore_code(&(this->c1), &(this->c2), this->c3, &(this->c4), &(this->c5), 
                    &(this->c6), &(this->c7), &(this->c8), this->c9, &(this->c10), 
                    &(this->c11), &(this->c12));
    oc_restore_input_info(this->i1, this->i2, this->i3, this->i4);
    oc_restore_cabcode(&(this->cc1), &(this->cc2));
}


// Helper class for MATLAB interface.
NrnRef::NrnRef(double* x) {
    this->ref = x;
    this->n_elements = 1;
}
NrnRef::NrnRef(double* x, size_t size) {
    this->ref = x;
    this->n_elements = size;
}
void NrnRef::set(double x) {
    *(this->ref) = x;
}
void NrnRef::set_index(double x, size_t ind) {
    if (ind < this->n_elements) {
        *(this->ref + ind) = x;
    } else {
        throw std::out_of_range("NrnRef index out of bounds");
    }
}
double NrnRef::get() {
    return *(this->ref);
}

double NrnRef::get_index(size_t ind) {
    if (ind < this->n_elements) {
        return *(this->ref + ind);
    } else {
        throw std::out_of_range("NrnRef index out of bounds");
    }
}

std::vector<double> get_x3d(Section* sec) {
    auto result = std::vector<double>(sec->npt3d);
    for (size_t i = 0; i < sec->npt3d; i++) {
        result[i] = sec->pt3d[i].x;
    }
    return result;
}

std::vector<double> get_y3d(Section* sec) {
    auto result = std::vector<double>(sec->npt3d);
    for (size_t i = 0; i < sec->npt3d; i++) {
        result[i] = sec->pt3d[i].y;
    }
    return result;
}

std::vector<double> get_z3d(Section* sec) {
    auto result = std::vector<double>(sec->npt3d);
    for (size_t i = 0; i < sec->npt3d; i++) {
        result[i] = sec->pt3d[i].z;
    }
    return result;
}

std::vector<double> get_arc3d(Section* sec) {
    auto result = std::vector<double>(sec->npt3d);
    for (size_t i = 0; i < sec->npt3d; i++) {
        result[i] = sec->pt3d[i].arc;
    }
    return result;
}

std::vector<double> get_d3d(Section* sec) {
    auto result = std::vector<double>(sec->npt3d);
    for (size_t i = 0; i < sec->npt3d; i++) {
        result[i] = sec->pt3d[i].d;
    }
    return result;
}

// Linearly interpolates between a and b, extrapolates if f is outside the range [0, 1].
// Added since we don't use c++ 20 or above where we could use:
// https://en.cppreference.com/w/cpp/numeric/lerp
double linearly_interpolate(double a, double b, double f) {
    return a + f * (b - a);
}

double interpolate_arrays(std::vector<double> xs, std::vector<double> ys, double v) {
    auto xs_iter = xs.begin() + 1;

    while(v > *xs_iter) {
        xs_iter++;
    }

    auto a = ys.begin() + ((xs_iter - 1) - xs.begin());
    auto b = ys.begin() + (xs_iter - xs.begin());
    double f = (v - *(xs_iter - 1)) / (*xs_iter - *(xs_iter - 1));

    return linearly_interpolate(*a, *b, f);
}

std::vector<double> get_segment_arc(Section* sec, double low, double high) {
    auto result = std::vector<double>();

    result.push_back(low);

    for (size_t i = 0; i < sec->npt3d; i++) {
        double arc = sec->pt3d[i].arc;

        if (arc > low && arc < high) {
            result.push_back(arc);
        }
    }

    result.push_back(high);

    return result;
}

std::vector<double> get_section_plot_data(Section* sec, ShapePlotInterface* spi) {
    auto result = std::vector<double>();

    size_t n_segments = sec->nnode - 1;
    double sec_length = section_length(sec);

    auto arcs = get_arc3d(sec);
    auto xs = get_x3d(sec);
    auto ys = get_y3d(sec);
    auto zs = get_z3d(sec);
    auto ds = get_d3d(sec);

    for (size_t i = 0; i < n_segments; i++) {
        double x_lo = (double) i / n_segments;
        double x_hi = (double) (i + 1) / n_segments;
        double x = (double) (i + 0.5) / n_segments;
        x_lo *= sec_length;
        x_hi *= sec_length;

        auto segment_arc = get_segment_arc(sec, x_lo, x_hi);

        double seg_value = *nrn_rangepointer(sec, hoc_lookup(spi->varname()), x);

        // Do one initial run
        result.push_back(interpolate_arrays(arcs, xs, segment_arc[0]));
        result.push_back(interpolate_arrays(arcs, xs, segment_arc[1]));
        result.push_back(interpolate_arrays(arcs, ys, segment_arc[0]));
        result.push_back(interpolate_arrays(arcs, ys, segment_arc[1]));
        result.push_back(interpolate_arrays(arcs, zs, segment_arc[0]));
        result.push_back(interpolate_arrays(arcs, zs, segment_arc[1]));
        result.push_back(interpolate_arrays(arcs, ds, segment_arc[0]));
        result.push_back(interpolate_arrays(arcs, ds, segment_arc[1]));
        result.push_back(seg_value);
        // Use initial run and reuse previously calculated values
        for (size_t j = 1; j < segment_arc.size() - 1; j++) {
            result.push_back(result[9 * j + 1]); // xs for segment j
            result.push_back(interpolate_arrays(arcs, xs, segment_arc[j + 1]));
            result.push_back(result[9 * j + 3]); // ys for segment j
            result.push_back(interpolate_arrays(arcs, ys, segment_arc[j + 1]));
            result.push_back(result[9 * j + 5]); // zs for segment j
            result.push_back(interpolate_arrays(arcs, zs, segment_arc[j + 1]));
            result.push_back(result[9 * j + 7]); // ds for segment j
            result.push_back(interpolate_arrays(arcs, ds, segment_arc[j + 1]));
            result.push_back(seg_value);
        }
    }

    return result;
}

// Used as hoc function with void return type and instance_id: string.
// Calls matlab function defined in static dictionary with key instance_id.
void finitialize_callback() {
    std::string instance_id = hoc_gargstr(1);
    std::string command = "neuron.FInitializeHandler.handlers(" + instance_id + ")";
    char* command_c = const_cast<char*>(command.c_str());

    mexEvalString(command_c);

    hoc_ret();
    hoc_pushx(0);
}

// Register and create FInitalizeHandler object in hoc,
// which is set to call finitialize_callback defined above with hoc argument instance_id
Object* create_FInitializeHandler(int type, const char* func_name, const char* instance_id) {
    // Register the the callback in hoc
    const int function_type = 280;
    Symbol* sym;
    sym = hoc_install(func_name, function_type, 0, &hoc_top_level_symlist);
    sym->u.u_proc->defn.pf = finitialize_callback;
    sym->u.u_proc->nauto = 0;
    sym->u.u_proc->nobjauto = 0;

    // Create hoc command for calling the callback with instance_id
    std::string command = func_name;
    std::string id = instance_id;
    command += "(\"" + id + "\")";
    char* command_c = const_cast<char*>(command.c_str());

    // Register FInitializeHandler object
    // calling the constructor with (type, command_c)
    int n_args = 2;
    hoc_pushx(type);
    hoc_pushstr(&command_c);
    auto ps = hoc_newobj1(hoc_lookup("FInitializeHandler"), n_args);
    return ps;
}

// Function to be called through hoc to run arbitrary matlab code
// passed as string argument.
void nrnmatlab() {
    std::string command = hoc_gargstr(1);
    char* command_c = const_cast<char*>(command.c_str());

    int status = mexEvalString(command_c);

    hoc_ret();
    hoc_pushx(status);
}

// Register nrnmatlab function in hoc.
// This calls the above nrnmatlab function.
void setup_nrnmatlab() {
    const int function_type = 280;
    Symbol* sym;
    sym = hoc_install("nrnmatlab", function_type, 0, &hoc_top_level_symlist);
    sym->u.u_proc->defn.pf = nrnmatlab;
    sym->u.u_proc->nauto = 0;
    sym->u.u_proc->nobjauto = 0;
}

std::vector<double> get_plot_data(ShapePlotInterface* spi) {
    auto result = std::vector<double>();

    hoc_Item* my_section_list;
    Object* sl = spi->neuron_section_list();
    if (sl) {
        my_section_list = (hoc_Item*) sl->u.this_pointer;
    } else {
        // no section list specified so use the global all sections list
        my_section_list = section_list;
    }

    auto section_iterator = my_section_list->next;
    while (true) {
        auto section = get_hoc_item_element_sec(section_iterator);
        if (section == NULL) break;

        auto sec_plot_data = get_section_plot_data(section, spi);
        result.insert(result.end(), sec_plot_data.begin(), sec_plot_data.end());

        section_iterator = section_iterator->next;
    }

    return result;
}
