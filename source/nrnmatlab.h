#include <string>
#include "neuron_api_headers.h"

class SavedState;
class NrnRef;

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
std::string matlab_hoc_strpop(void);
Object* matlab_hoc_objpop(void);

// Make a new section / delete section.
Section* new_section(const char* name);

// Set/get object property.
void set_pp_property(Object* pp, const char* name, double value, int element=0);
double get_pp_property(Object* pp, const char* name, int element=0);
NrnRef* ref_pp_property(Object* pp, const char* name, int element=0);
void set_steered_property(Object* obj, const char* name, double value);
double get_steered_property(Object* obj, const char* name);

// Set section length/diameter.
double get_dparam(Section* sec, int ind);
void set_dparam(Section* sec, int ind, double value);
void set_diam_changed(int value);
void set_node_diam(Node* node, double diam);

// Increase try/catch nest depth after catching an error.
int increase_try_catch_nest_depth();
int decrease_try_catch_nest_depth();

// Accessing sections & section lists.
hoc_Item* get_section_list();
Section* get_hoc_item_element_sec(hoc_Item*);
hoc_Item* get_obj_u_this_pointer(Object*);
ShapePlotInterface* get_plotshape_interface(Object*);

// Special case: set/get n.secondorder.
void set_secondorder(int);
int get_secondorder(void);

// C++ Neuron functions directly accessible from MATLAB.
#ifdef _WIN32
#define MANGLED __declspec(dllimport)
#define NON_MANGLED extern "C" __declspec(dllimport)
#elif __APPLE__ || __linux__
#define MANGLED extern
#define NON_MANGLED extern "C"
#else
#   error "Unknown compiler / OS"
#endif

MANGLED Node* node_exact(Section*, double);
MANGLED void nrn_pushsec(Section* sec);
MANGLED void hoc_obj_unref(Object*);
MANGLED double hoc_call_func(Symbol*, int);
MANGLED void hoc_call_ob_proc(Object*, Symbol*, int);
MANGLED Symbol* hoc_lookup(const char*);
MANGLED void hoc_push_object(Object*);
MANGLED void hoc_pushx(double);
MANGLED Symbol* hoc_table_lookup(const char*, Symlist*);
MANGLED double hoc_xpop(void);
MANGLED int hoc_oc(const char*);
MANGLED void hoc_l_delete(hoc_Item*);
MANGLED void delete_section(void);
MANGLED Object* hoc_newobj1(Symbol*, int);
MANGLED void nrn_change_nseg(Section*, int);
MANGLED void nrn_length_change(Section*, double);
MANGLED void mech_insert1(Section*, int);
MANGLED Section* nrn_sec_pop(void);
MANGLED void section_unref(Section*);
MANGLED void simpleconnectsection(void);
MANGLED char* secname(Section*);

// Pointer class for MATLAB interface.
class NrnRef { /* Holds a pointer to a double. */
    public:
        double* ref;
        NrnRef(double* x);
        void set(double x);
        double get();
};

// State
class SavedState {
    public:
        SavedState();
        void restore();

    private:
        // hoc_oop
        Object* o1;
        Objectdata* o2;
        int o4;
        Symlist* o5;

        // code
        Inst* c1;
        Inst* c2;
        std::size_t c3;
        void* c4;
        int c5;
        int c6;
        Inst* c7;
        void* c8;
        std::size_t c9;
        Symlist* c10;
        Inst* c11;
        int c12;

        // input_info
        const char* i1;
        int i2;
        int i3;
        void* i4;

        // cabcode
        int cc1;
        int cc2;
};