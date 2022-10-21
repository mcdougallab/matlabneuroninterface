#include <string>
#include "neuron_api_headers.h"
#include "neuron_matlab_headers.h"

// Initialize NEURON session.
void initialize();
bool isinitialized();

// Call a few hoc functions.
void create_soma();
void print_t_v();
void topology();
void finitialize(double finitialize_val);

// Run simulation.
void fadvance();

// Get pointer to top-level symbol.
NrnRef* ref(const char* tlsym);

// Get pointer from nrn_rangepointer.
NrnRef* range_ref(Section* sec, const char* sym, double val);

// Print all class methods & attributes to stdout.
void print_class_methods(const char* class_name);

// Return all class methods & attributes as a string with separators ";"
// between methods, and ":" between method name and method type.
std::string get_class_methods(const char* class_name);

// Vector object.
int get_vector_capacity(Object* vec);
const double* get_vector_vec(Object* vec, int len);
Object* get_vector(int vector_value);

// Calling Object methods from MATLAB.
Symbol* get_method_sym(Object* ob, const char* methodname);
void matlab_hoc_call_ob_proc(Object* ob, Symbol* sym, int narg);
void matlab_hoc_pushx(double x);
void matlab_hoc_pushpx(NrnRef* nrnref);
void matlab_hoc_pushstr(std::string str);
void matlab_hoc_pushobj(Object* ob);
double matlab_hoc_xpop(void);
std::string matlab_hoc_strpop(void);
Object* matlab_hoc_objpop(void);

// Record.
void record(Object* vec, NrnRef* nrnref);

// Make a new section.
Section* new_section(const char* name);

// Insert mechanism into section.
void insert_mechanism(Section* sec, const char* mech_name);

// Set/get object property.
void set_pp_property(Object* pp, const char* name, double value);
double get_pp_property(Object* pp, const char* name);

// Get IClamp object.
Object* get_IClamp(double loc);

// C++ Neuron functions directly accessible from MATLAB.
extern "C" __declspec(dllimport) void nrn_popsec(void);
extern "C" __declspec(dllimport) void nrn_pushsec(Section* sec);
