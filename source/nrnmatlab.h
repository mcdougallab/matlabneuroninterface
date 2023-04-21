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
void set_pp_property(Object* pp, const char* name, double value);
double get_pp_property(Object* pp, const char* name);
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

// C++ Neuron functions directly accessible from MATLAB.
__declspec(dllimport) Node* node_exact(Section*, double);
__declspec(dllimport) void nrn_pushsec(Section* sec);
__declspec(dllimport) void hoc_obj_unref(Object*);
__declspec(dllimport) double hoc_call_func(Symbol*, int);
__declspec(dllimport) void hoc_call_ob_proc(Object*, Symbol*, int);
__declspec(dllimport) Symbol* hoc_lookup(const char*);
__declspec(dllimport) void hoc_push_object(Object*);
__declspec(dllimport) void hoc_pushx(double);
__declspec(dllimport) Symbol* hoc_table_lookup(const char*, Symlist*);
__declspec(dllimport) double hoc_xpop(void);
__declspec(dllimport) int hoc_oc(const char*);
__declspec(dllimport) void hoc_l_delete(hoc_Item*);
__declspec(dllimport) void delete_section(void);
__declspec(dllimport) Object* hoc_newobj1(Symbol*, int);
__declspec(dllimport) void nrn_change_nseg(Section*, int);
__declspec(dllimport) void nrn_length_change(Section*, double);
__declspec(dllimport) void mech_insert1(Section*, int);
__declspec(dllimport) Section* nrn_sec_pop(void);
__declspec(dllimport) void section_unref(Section*);
__declspec(dllimport) void simpleconnectsection(void);
__declspec(dllimport) char* secname(Section*);

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