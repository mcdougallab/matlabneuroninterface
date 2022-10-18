#include <assert.h>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cstdint>
#include <cstring>
#include <string>
#include "neuron_api_headers.h"
#include "neuron_matlab_headers.h"

// Import C++ name mangled functions.
__declspec(dllimport) optrsptri_function hoc_newobj1;
__declspec(dllimport) initer_function ivocmain_session;
__declspec(dllimport) vsecptri_function mech_insert1;
__declspec(dllimport) voptrsptritemptrptri_function new_sections;
__declspec(dllimport) vv_function nrnmpi_stubs;
__declspec(dllimport) dptrsecptrsptrd_function nrn_rangepointer;

// Import non-name mangled functions and parameters.
extern "C" __declspec(dllimport) dvptrint_function hoc_call_func;
extern "C" __declspec(dllimport) voptrsptri_function hoc_call_ob_proc;
extern "C" __declspec(dllimport) dsio_function hoc_call_objfunc;
extern "C" __declspec(dllimport) vsptr_function hoc_install_object_data_index;
extern "C" __declspec(dllimport) scptr_function hoc_lookup;
extern "C" __declspec(dllimport) voptr_function hoc_obj_ref;
extern "C" __declspec(dllimport) Objectdata* hoc_objectdata;
extern "C" __declspec(dllimport) icptr_function hoc_oc;
extern "C" __declspec(dllimport) vcptrptr_function hoc_pushstr;
extern "C" __declspec(dllimport) vdptr_function hoc_pushpx;
extern "C" __declspec(dllimport) vd_function hoc_pushx;
extern "C" __declspec(dllimport) vv_function hoc_ret;
extern "C" __declspec(dllimport) scptrslptr_function hoc_table_lookup;
extern "C" __declspec(dllimport) dv_function hoc_xpop;
extern "C" __declspec(dllimport) int nrn_main_launch;
extern "C" __declspec(dllimport) int nrn_nobanner_;
extern "C" __declspec(dllimport) ppoptr_function ob2pntproc_0;
extern "C" __declspec(dllimport) ivptr_function vector_capacity;
extern "C" __declspec(dllimport) dptrvptr_function vector_vec;

// Define invocmain_session input.
static const char* argv[] = {"nrn_test", "-nogui", "-nopython", NULL};

// Initialize NEURON session.
bool initialized = false;
void initialize(){

    if (!initialized) {
        // Redirect stdout/sterr output to file, because MATLAB cannot handle 
        // it directly. Maybe we can use GetStdHandle instead?
        freopen("stdout.txt", "w", stdout);
        freopen("stderr.txt", "w", stderr);
    
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

// Create soma.
void create_soma(){
    hoc_oc("create soma\n");
}

// Topology.
void topology(){
    hoc_call_func(hoc_lookup("topology"), 0);
}

// Finitialize.
void finitialize(double finitialize_val){
    hoc_pushx(finitialize_val);
    hoc_call_func(hoc_lookup("finitialize"), 1);
    std::cout << "time and voltage:" << std::endl;
    hoc_oc("print t, v\n");
}

// Run simulation time step.
void fadvance(){
    hoc_call_func(hoc_lookup("fadvance"), 0);
    // std::cout << "time and voltage:" << std::endl;
    // hoc_oc("print t, v\n");
}

// Finish up: close stdout and stderr output files.
// TODO: this does not properly end the session.
void close(){
    fclose(stdout);
    fclose(stderr);
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

// Print all Vector methods & attributes.
// TODO: can we use this to automatically populate the MATLAB Vector class methods?
void print_symbol_table(Symlist* table) {
    for (Symbol* sp = table->first; sp != NULL; sp = sp->next) {
        // type distinguishes methods from properties, return type
        std::cout << "-- " << sp->name << " (" << sp->type << ")\n";
    }
    std::cout << std::endl;
}
void print_class_methods(const char* class_name) {
    auto sym = hoc_lookup(class_name);
    assert(sym);
    std::cout << sym->name << " properties and methods:" << std::endl;
    print_symbol_table(sym->u.ctemplate->symtable);
}
// Return all class methods & attributes as a string with separators ";"
// between methods, and ":" between method name and method type.
std::string get_class_methods(const char* class_name) {
    std::string methods, new_method;
    auto sym = hoc_lookup(class_name);
    Symlist* table = sym->u.ctemplate->symtable;

    for (Symbol* sp = table->first; sp != NULL; sp = sp->next) {
        new_method = std::string(sp->name) + ":" + 
                     std::to_string(sp->type) + ";";
        methods = methods + new_method;
    }

    return methods;
}

// Get Vector size.
int get_vector_capacity(Object* vec){
    return vector_capacity(vec->u.this_pointer);
}

// Get Vector data.
const double* get_vector_vec(Object* vec, int len){
    return vector_vec(vec->u.this_pointer);
}

// Calculate a Vector property that returns a double, like mean, min, stdev, ...
double vector_double_method(Object* vec, const char* methodname){
    auto sym = hoc_table_lookup(methodname, vec->ctemplate->symtable);
    assert(sym);
    hoc_call_ob_proc(vec, sym, 0);
    return hoc_xpop();
}

// Record.
void record(Object* vec, NrnRef* nrnref) {
    hoc_pushpx(nrnref->ref);
    auto sym = hoc_table_lookup("record", vec->ctemplate->symtable);
    hoc_call_ob_proc(vec, sym, 1);
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
