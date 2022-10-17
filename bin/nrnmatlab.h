#include "neuron_api_headers.h"
#include "neuron_matlab_headers.h"

// Initialize NEURON session.
void initialize();

// Call a few hoc functions.
void create_soma();
void topology();
void finitialize(double finitialize_val);

// Run simulation.
void fadvance();

// Get pointer to top-level symbol.
NrnRef* ref(const char* tlsym);

// Get pointer from nrn_rangepointer.
NrnRef* range_ref(Section* sec, const char* sym, double val);

// Print all class methods & attributes.
void print_class_methods(const char* class_name);

// Vector object.
int get_vector_capacity(Object* vec);
const double* get_vector_vec(Object* vec, int len);
double vector_double_method(Object* vec, const char* methodname);
Object* get_vector(int vector_value);

// Record.
void record(Object* vec, NrnRef* nrnref);

// Finish up: close stdout and stderr output files.
void close();

// Make a new section.
Section* new_section(const char* name);

// Insert mechanism into section.
void insert_mechanism(Section* sec, const char* mech_name);

// Set/get object property.
void set_pp_property(Object* pp, const char* name, double value);
double get_pp_property(Object* pp, const char* name);

// Get IClamp object.
Object* get_IClamp(double loc);