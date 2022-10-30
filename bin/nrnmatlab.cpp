#include <assert.h>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cstdint>
#include <cstring>
#include <string>
#include "neuron_api_headers.h"
#include "neuron_dllimports.h"
#include "neuron_matlab_headers.h"

// Declare mexPrintf
// We cannot include mex.h with clib, because during build will give
// "error Using MATLAB Data API with C Matrix API is not supported."
extern "C" int mexPrintf(const char *message, ...);

// Define invocmain_session input.
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

// Return all functions/methods/attributes as a string with separators ";"
// between methods, and ":" between method name and method type.
std::string str_symbol_table(Symlist* table) {
    std::string tabstr, new_tabstr;
    for (Symbol* sp = table->first; sp != NULL; sp = sp->next) {
        new_tabstr = std::string(sp->name) + ":" + 
                     std::to_string(sp->type) + ";";
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

// Pushing/popping objects onto/from the stack.
void matlab_hoc_pushpx(NrnRef* nrnref) {
    hoc_pushpx(nrnref->ref);
}
void matlab_hoc_pushstr(const char* strin) {
    static char* cptr = new char[strlen(strin)];
    strcpy(cptr, strin);
    hoc_pushstr(&cptr);
}
void matlab_hoc_pushobj(Object* ob) {
    hoc_pushobj(&ob);
}
std::string matlab_hoc_strpop(void) {
    std::string str_out = std::string(*hoc_strpop());
    return str_out;
}
Object* matlab_hoc_objpop(void) {
    Object** obptr = hoc_objpop();
    Object* ob = *obptr;
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
void set_pp_property(Object* pp, const char* name, double value) {
    int index = hoc_table_lookup(name, pp->ctemplate->symtable)->u.rng.index;
    ob2pntproc_0(pp)->prop->param[index] = value;
}
double get_pp_property(Object* pp, const char* name) {
    int index = hoc_table_lookup(name, pp->ctemplate->symtable)->u.rng.index;
    return ob2pntproc_0(pp)->prop->param[index];
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
