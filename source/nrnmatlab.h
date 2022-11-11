#include <string>
#include "neuron_api_headers.h"
#include "neuron_matlab_headers.h"

// Initialize NEURON session.
void initialize();
bool isinitialized();

// Return all top-level functions.
std::string get_nrn_functions();

// Get pointer to top-level symbol.
NrnRef* ref(const char* tlsym);

// Get pointer from nrn_rangepointer.
NrnRef* range_ref(Section* sec, const char* sym, double val);

// Return all object methods & attributes.
std::string get_class_methods(const char* class_name);

// Vector object.
int get_vector_capacity(Object* vec);
const double* get_vector_vec(Object* vec, int len);

// Pushing/popping objects onto/from the stack.
void matlab_hoc_pushpx(NrnRef* nrnref);
void matlab_hoc_pushstr(const char* strin);
void matlab_hoc_pushobj(Object* ob);
std::string matlab_hoc_strpop(void);
Object* matlab_hoc_objpop(void);

// Make a new section / delete section.
Section* new_section(const char* name);

// Set/get object property.
void set_pp_property(Object* pp, const char* name, double value);
double get_pp_property(Object* pp, const char* name);

// Set section length/diameter.
double get_dparam(Section* sec, int ind);
void set_dparam(Section* sec, int ind, double value);
void set_diam_changed(int value);
void set_node_diam(Node* node, double diam);

// C++ Neuron functions directly accessible from MATLAB.
Node* node_exact(Section*, double);
void nrn_pushsec(Section* sec);
void hoc_obj_unref(Object*);
double hoc_call_func(Symbol*, int);
void hoc_call_ob_proc(Object*, Symbol*, int);
Symbol* hoc_lookup(const char*);
void hoc_pushx(double);
Symbol* hoc_table_lookup(const char*, Symlist*);
double hoc_xpop(void);
int hoc_oc(const char*);
void delete_section(void);
Object* hoc_newobj1(Symbol*, int);
void nrn_change_nseg(Section*, int);
void nrn_length_change(Section*, double);
void mech_insert1(Section*, int);
Section* nrn_sec_pop(void);
void section_unref(Section*);
void simpleconnectsection(void);