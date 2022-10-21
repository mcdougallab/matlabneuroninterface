#include <assert.h>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cstdint>
#include <cstring>
#include <string>
#include "neuron_api_headers.h"
#include "neuron_matlab_headers.h"

// Declare mexPrintf
// We cannot include mex.h with clib, because during build will give
// "error Using MATLAB Data API with C Matrix API is not supported."
extern "C" int mexPrintf(const char *message, ...);

// Import C++ name mangled functions.
__declspec(dllimport) optrsptri_function hoc_newobj1;
__declspec(dllimport) initer_function ivocmain_session;
__declspec(dllimport) vsecptri_function mech_insert1;
__declspec(dllimport) voptrsptritemptrptri_function new_sections;
__declspec(dllimport) vv_function nrnmpi_stubs;
__declspec(dllimport) dptrsecptrsptrd_function nrn_rangepointer;

// Import non-name mangled functions and parameters.
extern "C" __declspec(dllimport) Symlist* hoc_built_in_symlist;
extern "C" __declspec(dllimport) dvptrint_function hoc_call_func;
extern "C" __declspec(dllimport) voptrsptri_function hoc_call_ob_proc;
extern "C" __declspec(dllimport) dsio_function hoc_call_objfunc;
extern "C" __declspec(dllimport) vsptr_function hoc_install_object_data_index;
extern "C" __declspec(dllimport) scptr_function hoc_lookup;
extern "C" __declspec(dllimport) voptr_function hoc_obj_ref;
extern "C" __declspec(dllimport) Objectdata* hoc_objectdata;
extern "C" __declspec(dllimport) optrptrv_function hoc_objpop;
extern "C" __declspec(dllimport) icptr_function hoc_oc;
extern "C" __declspec(dllimport) voptrptr_function hoc_pushobj;
extern "C" __declspec(dllimport) vdptr_function hoc_pushpx;
extern "C" __declspec(dllimport) vcptrptr_function hoc_pushstr;
extern "C" __declspec(dllimport) vd_function hoc_pushx;
extern "C" __declspec(dllimport) vv_function hoc_ret;
extern "C" __declspec(dllimport) cptrptrv_function hoc_strpop;
extern "C" __declspec(dllimport) scptrslptr_function hoc_table_lookup;
extern "C" __declspec(dllimport) voptrptr_function hoc_tobj_unref;
extern "C" __declspec(dllimport) Symlist* hoc_top_level_symlist;
extern "C" __declspec(dllimport) dv_function hoc_xpop;
extern "C" __declspec(dllimport) int nrn_is_python_extension;
extern "C" __declspec(dllimport) int nrn_main_launch;
extern "C" __declspec(dllimport) int nrn_nobanner_;
extern "C" __declspec(dllimport) vf2icif_function nrnpy_set_pr_etal;
extern "C" __declspec(dllimport) ppoptr_function ob2pntproc_0;
extern "C" __declspec(dllimport) ivptr_function vector_capacity;
extern "C" __declspec(dllimport) dptrvptr_function vector_vec;


// Define invocmain_session input.
static const char* argv[] = {"nrn_test", "-nogui", "-nopython", NULL};

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
bool initialized = false;
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

// Call hoc_oc from MATLAB.
void matlab_hoc_oc(std::string hoc_str) {
    hoc_oc((hoc_str + "\n").c_str());
}

// Call function from MATLAB.
void matlab_hoc_call_func(std::string func, int narg){
    hoc_call_func(hoc_lookup(func.c_str()), narg);
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

// Calling Object methods from MATLAB.
Symbol* get_method_sym(Object* ob, const char* methodname){
    return hoc_table_lookup(methodname, ob->ctemplate->symtable);
}
void matlab_hoc_call_ob_proc(Object* ob, Symbol* sym, int narg) {
    hoc_call_ob_proc(ob, sym, narg);
}

// Pushing/popping objects onto/from the stack.
void matlab_hoc_pushx(double x) {
    hoc_pushx(x);
}
void matlab_hoc_pushpx(NrnRef* nrnref) {
    hoc_pushpx(nrnref->ref);
}
void matlab_hoc_pushstr(std::string str) {
    char* strchr = const_cast<char*>(str.c_str());
    hoc_pushstr(&strchr);
}
void matlab_hoc_pushobj(Object* ob) {
    hoc_pushobj(&ob);
}
double matlab_hoc_xpop(void) {
    return hoc_xpop();
}
std::string matlab_hoc_strpop(void) {
    std::string str_out = std::string(*hoc_strpop());
    return str_out;
}
Object* matlab_hoc_objpop(void) {
    Object** obptr = hoc_objpop();
    Object* ob = *obptr;
    // hoc_tobj_unref(obptr);
    return ob;
}

// Make and return Vector.
Object* get_vector(int vector_value){

    Object* my_vec = NULL;
    // print_class_methods("Vector");
    if (vector_value > 0) {
        hoc_pushx(vector_value);
        my_vec = hoc_newobj1(hoc_lookup("Vector"), 1);
    } else {
        my_vec = hoc_newobj1(hoc_lookup("Vector"), 0);
    }

    return my_vec;
}

// Make and return a new section.
Section* new_section(const char* name) {
    Symbol* symbol = new Symbol;
    auto pitm = new hoc_Item*;
    char* name_ptr = new char[strlen(name)];
    strcpy(name_ptr, name);
    symbol->name = name_ptr;
    symbol->type = 1;
    hoc_install_object_data_index(symbol);
    new_sections(nullptr, symbol, pitm, 1);
    return (*pitm)->element.sec;
}

// Insert mechanism into section.
void insert_mechanism(Section* sec, const char* mech_name) {
    auto sym = hoc_lookup(mech_name);
    assert(sym);
    // the type indicates that it's a mechanism; the subtype indicates which
    mech_insert1(sec, sym->subtype);
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

// Get IClamp object.
Object* get_IClamp(double loc) {
    hoc_pushx(loc);
    auto iclamp = hoc_newobj1(hoc_lookup("IClamp"), 1);
    return iclamp;
}