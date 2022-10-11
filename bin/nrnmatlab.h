#include "neuron_api_headers.h"

// Initialize NEURON session.
void initialize();

// Call a few hoc functions.
void hoc_run(double finitialize_val);

// Run simulation.
void fadvance();

// Test vector object.
int get_vector_capacity(Object* vec);
const double* get_vector_vec(Object* vec, int len);
double vector_double_method(Object* vec, const char methodname[]);
Object* get_vector(int vector_value);

// Finish up: close stdout and stderr output files.
void close();