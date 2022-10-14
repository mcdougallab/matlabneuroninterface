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

// Test vector object.
int get_vector_capacity(Object* vec);
const double* get_vector_vec(Object* vec, int len);
double vector_double_method(Object* vec, const char methodname[]);
Object* get_vector(int vector_value);

// Record.
void record(Object* vec, NrnRef* nrnref);

// Finish up: close stdout and stderr output files.
void close();