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
