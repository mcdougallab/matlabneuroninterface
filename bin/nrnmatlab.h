#include <string>
#include "neuron_api_headers.h"
#include "neuron_matlab_headers.h"

// Initialize NEURON session.
void initialize();
bool isinitialized();

// Return all top-level functions.
std::string get_nrn_functions();

// Call hoc_oc from MATLAB.
void matlab_hoc_oc(std::string hoc_str);

// Call function from MATLAB.
double matlab_hoc_call_func(std::string func, int narg);

// Get pointer to top-level symbol.
NrnRef* ref(const char* tlsym);

// Get pointer from nrn_rangepointer.
NrnRef* range_ref(Section* sec, const char* sym, double val);

// Return all object methods & attributes.
std::string get_class_methods(const char* class_name);

// Vector object.
int get_vector_capacity(Object* vec);
const double* get_vector_vec(Object* vec, int len);
Object* get_vector(int vector_value);

// Calling Object methods from MATLAB.
Symbol* get_method_sym(Object* ob, const char* methodname);
void matlab_hoc_call_ob_proc(Object* ob, Symbol* sym, int narg);

// Pushing/popping objects onto/from the stack.
void matlab_hoc_pushx(double x);
void matlab_hoc_pushpx(NrnRef* nrnref);
void matlab_hoc_pushstr(std::string str);
void matlab_hoc_pushobj(Object* ob);
double matlab_hoc_xpop(void);
std::string matlab_hoc_strpop(void);
Object* matlab_hoc_objpop(void);

// Make a new section.
Section* new_section(const char* name);

// Insert mechanism into section.
void insert_mechanism(Section* sec, const char* mech_name);

// Set/get object property.
void set_pp_property(Object* pp, const char* name, double value);
double get_pp_property(Object* pp, const char* name);

// Get IClamp object.
Object* get_IClamp(double loc);

// Connect sections.
void connect(Section* child_sec, double child_x, Section* parent_sec, double parent_x);

// Add 3D point to Section.
void pt3dadd(Section* sec, double x, double y, double z, double diam);

// Set section length/diameter.
void set_length(Section* sec, double length);
double get_length(Section* sec);
void set_diameter(Section* sec, double diam);

// Get section info.
void print_3d_points_and_segs(Section* sec);

// C++ Neuron functions directly accessible from MATLAB.
extern "C" void nrn_pushsec(Section* sec);
extern "C" void hoc_obj_unref(Object*);
void nrn_change_nseg(Section*, int);
void section_unref(Section*);
Section* nrn_sec_pop(void);