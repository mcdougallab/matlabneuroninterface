#include <iostream>
#include <cstdlib>
#include <assert.h>
#include "neuron_api_headers.h"
#include "neuron_matlab_headers.h"

// Import C++ name mangled functions.
__declspec(dllimport) void ivocmain_session(int, const char**, 
                                            const char**, int);
__declspec(dllimport) Object* hoc_newobj1(Symbol*, int);
__declspec(dllimport) void nrnmpi_stubs();

// Import non-name mangled functions and parameters.
extern "C" __declspec(dllimport) int hoc_oc(const char*);
extern "C" __declspec(dllimport) Symbol* hoc_lookup(const char*);
extern "C" __declspec(dllimport) double hoc_call_func(void*, int);
extern "C" __declspec(dllimport) void hoc_pushx(double);
extern "C" __declspec(dllimport) void hoc_pushpx(double*);
extern "C" __declspec(dllimport) int vector_capacity(void*);
extern "C" __declspec(dllimport) double* vector_vec(void*);
extern "C" __declspec(dllimport) double hoc_xpop(void);
extern "C" __declspec(dllimport) void hoc_call_ob_proc(Object*, Symbol*, int);
extern "C" __declspec(dllimport) Symbol* hoc_table_lookup(const char*, Symlist*);
extern "C" __declspec(dllimport) int nrn_main_launch;
extern "C" __declspec(dllimport) int nrn_nobanner_;

// Define invocmain_session input.
static const char* argv[] = {"nrn_test", "-nogui", "-nopython", NULL};

// Initialize NEURON session.
void initialize(){
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
    std::cout << "time and voltage:" << std::endl;
    hoc_oc("print t, v\n");
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

// Print all Vector methods & attributes.
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

// Get Vector size.
int get_vector_capacity(Object* vec){
    return vector_capacity(vec->u.this_pointer);
}

// Get Vector data.
const double* get_vector_vec(Object* vec, int len){
    return vector_vec(vec->u.this_pointer);
}

// Calculate a Vector property that returns a double, like mean, min, stdev, ...
double vector_double_method(Object* vec, const char methodname[]){
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
        // Set vector data to something.
        double* vec_data = vector_vec(my_vec->u.this_pointer);
        for (auto i = 0; i < vector_capacity(my_vec->u.this_pointer); i++) {
            vec_data[i] = i * i;
        }
    } else {
        my_vec = hoc_newobj1(hoc_lookup("Vector"), 0);
    }

    std::cout << "my_vec address: " << my_vec << std::endl;
    return my_vec;
}