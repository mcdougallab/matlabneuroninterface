// compile via: mex CXXFLAGS="-std=c++17" neuron_api.cpp
#include "mex.h"
#include "/usr/local/include/neuronapi.h"
#include <stdio.h>
#include <array>
#include <tuple>
#include <unordered_map>
#include <string>
#include <vector>
#include <cstdint>
#include <cstring>


#ifdef _WIN32
    #include <windows.h>
    #define DLL_HANDLE HMODULE
    #define DLL_LOAD(name) LoadLibrary(name)
    #define DLL_GET_PROC(handle, name) GetProcAddress(handle, name)
    #define DLL_FREE(handle) FreeLibrary(handle)
    #define DLL_ERROR() "Error loading library"
#else
    #include <dlfcn.h>
    #define DLL_HANDLE void*
    #define DLL_LOAD(name) dlopen(name, RTLD_NOW)
    #define DLL_GET_PROC(handle, name) dlsym(handle, name)
    #define DLL_FREE(handle) dlclose(handle)
    #define DLL_ERROR() dlerror()
#endif


typedef void (*MxFunctionPtr)(const mxArray*, mxArray*);

Section* (*nrn_section_new_)(char const* name) = nullptr;
void (*nrn_hoc_call_)(char const* command) = nullptr;
void (*nrn_double_push_)(double) = nullptr;
double (*nrn_double_pop_)(void) = nullptr;
void (*nrn_function_call_)(Symbol* sym, int narg) = nullptr;

Symlist* (*nrn_global_symbol_table_)(void) = nullptr;
Symlist* (*nrn_top_level_symbol_table_)(void) = nullptr;

SymbolTableIterator* (*nrn_symbol_table_iterator_new_)(Symlist* my_symbol_table) = nullptr;
void (*nrn_symbol_table_iterator_free_)(SymbolTableIterator* st) = nullptr;
Symbol* (*nrn_symbol_table_iterator_next_)(SymbolTableIterator* st) = nullptr;
int (*nrn_symbol_table_iterator_done_)(SymbolTableIterator* st) = nullptr;
Symlist* (*nrn_symbol_table_)(Symbol* sym) = nullptr;

SectionListIterator* (*nrn_sectionlist_iterator_new_)(nrn_Item*) = nullptr;
void (*nrn_sectionlist_iterator_free_)(SectionListIterator*) = nullptr;
Section* (*nrn_sectionlist_iterator_next_)(SectionListIterator*) = nullptr;
int (*nrn_sectionlist_iterator_done_)(SectionListIterator*) = nullptr;

Symbol* (*nrn_symbol_)(char const* const name) = nullptr;
int (*nrn_symbol_type_)(const Symbol* sym) = nullptr;
int (*nrn_symbol_subtype_)(const Symbol* sym) = nullptr;
char const* (*nrn_symbol_name_)(const Symbol* sym) = nullptr;
double* (*nrn_symbol_dataptr_)(Symbol* sym) = nullptr;
bool (*nrn_symbol_is_array_)(Symbol*) = nullptr;
int (*nrn_symbol_array_length_)(Symbol*) = nullptr;

Symbol* (*hoc_install_)(const char*, int, double, Symlist**) = nullptr;
void (*nrn_register_function_)(void (*)(), const char*, int type) = nullptr;
char* (*hoc_gargstr_)(int) = nullptr;
void (*hoc_ret_)(void) = nullptr;
void (*hoc_pushx_)(double) = nullptr;
double (*hoc_xpop_)(void) = nullptr;
void (*hoc_call_ob_proc_)(Object*, Symbol*, int) = nullptr;
void (*nrn_symbol_push_)(Symbol*) = nullptr;

Object* (*nrn_object_new_)(Symbol* sym, int narg) = nullptr;
void (*nrn_object_unref_)(Object*) = nullptr;
char const* (*nrn_class_name_)(const Object*) = nullptr;
Symbol* (*nrn_method_symbol_)(Object*, char const* const) = nullptr;
void (*nrn_method_call_)(Object*, Symbol*, int) = nullptr;
bool (*nrn_prop_exists_)(const Object*) = nullptr;

double* (*nrn_vector_data_)(Object*) = nullptr;

void (*nrn_section_pop_)(void) = nullptr;
char** (*nrn_pop_str_)(void) = nullptr;
Object* (*nrn_object_pop_)(void) = nullptr;
double* (*nrn_double_ptr_pop_)(void) = nullptr;

void (*nrn_str_push_)(char**) = nullptr;
void (*nrn_object_push_)(Object*) = nullptr;
void (*nrn_double_ptr_push_)(double*) = nullptr;
void (*nrn_section_push_)(Section*) = nullptr;
void (*nrn_rangevar_push_)(Symbol*, Section*, double) = nullptr;
void (*nrn_property_push_)(Object*, const char*) = nullptr;
void (*nrn_property_array_push_)(Object*, const char*, int) = nullptr;

nrn_Item* (*nrn_allsec_)(void) = nullptr;
nrn_Item* (*nrn_sectionlist_data_)(Object*) = nullptr;
void (*nrn_mechanism_insert_)(Section*, const Symbol*) = nullptr;
double (*nrn_rangevar_get_)(Symbol*, Section*, double) = nullptr;
void (*nrn_rangevar_set_)(Symbol*, Section*, double, double) = nullptr;
void (*nrn_section_connect_)(Section*, double, Section*, double) = nullptr;
void (*nrn_section_length_set_)(Section*, double) = nullptr;
double (*nrn_section_length_get_)(Section*) = nullptr;
const char* (*nrn_secname_)(Section*) = nullptr;
int (*nrn_nseg_get_)(Section const*) = nullptr;
void (*nrn_nseg_set_)(Section*, const int) = nullptr;
double (*nrn_section_Ra_get_)(Section*) = nullptr;
void (*nrn_section_Ra_set_)(Section*, double) = nullptr;
double (*nrn_section_rallbranch_get_)(Section*) = nullptr;
void (*nrn_section_rallbranch_set_)(Section*, double) = nullptr;
void (*nrn_segment_diam_set_)(Section*, const double, const double) = nullptr;
double (*nrn_segment_diam_get_)(Section* const, const double) = nullptr;
bool (*nrn_section_is_active_)(Section*) = nullptr;
void (*nrn_section_ref_)(Section*) = nullptr;
void (*nrn_section_unref_)(Section*) = nullptr;
Section* (*nrn_cas_)(void) = nullptr;

double (*nrn_property_get_)(Object const*, const char*) = nullptr;
double (*nrn_property_array_get_)(Object const*, const char*, int) = nullptr;
void (*nrn_property_set_)(Object*, const char*, double) = nullptr;
void (*nrn_property_array_set_)(Object*, const char*, int, double) = nullptr;

ShapePlotInterface* (*nrn_get_plotshape_interface_)(Object*) = nullptr;
Object* (*nrn_get_plotshape_section_list_)(ShapePlotInterface*) = nullptr;
const char* (*nrn_get_plotshape_varname_)(ShapePlotInterface*) = nullptr;
float (*nrn_get_plotshape_low_)(ShapePlotInterface*) = nullptr;
float (*nrn_get_plotshape_high_)(ShapePlotInterface*) = nullptr;

bool has_inited = false;
DLL_HANDLE neuron_handle = nullptr;
std::unordered_map<std::string, void(*)(const mxArray**, mxArray**)> function_map;

// Print to MATLAB command window.
int mlprint(int stream, char* msg) {
    // stream = 1 for stdout; otherwise stderr
    if (stream == 1) {
        mexPrintf(msg);
    } else {
        // We could add something to error messages here.
        mexPrintf(msg);
    }
    return 0;
}

std::string getStringFromMxArray(const mxArray* mxStr) {
    if (mxGetClassID(mxStr) != mxCHAR_CLASS && !(mxIsClass(mxStr, "string"))) {
        mexErrMsgIdAndTxt("MyModule:invalidInput", "Input must be a string.");
    }

    if (mxIsClass(mxStr, "string")) {
        // Convert MATLAB string object to char array using mexCallMATLAB
        mxArray* pArrayChar = nullptr;
        mxArray* pArrayString = const_cast<mxArray*>(mxStr);
        int rc = mexCallMATLAB(1, &pArrayChar, 1, &pArrayString, "char");
        if (rc != 0 || pArrayChar == nullptr) {
            mexErrMsgIdAndTxt("MyModule:conversionError", "Failed to convert MATLAB string to char array.");
        }
        mxStr = pArrayChar;
    }

    // Get the number of characters in the string
    mwSize length = mxGetNumberOfElements(mxStr);

    // Allocate memory for the string plus null terminator
    std::string result(length, '\0');

    // Copy the string into the allocated buffer
    mxGetString(mxStr, &result[0], length + 1);

    return result;
}

// Helper class for MATLAB interface.
struct NrnRef {
    enum class RefClass { Vector, Symbol, RangeVar, ObjectProp, Unknown };
    RefClass ref_class = RefClass::Unknown;
    std::string name;
    Object* obj = nullptr;
    Symbol* sym = nullptr;
    Section* sec = nullptr;
    double x = 0.0;
    size_t n_elements = 1;
    int index = -1; // For ObjectProp and Vector indices

    // Vector reference
    NrnRef(Object* o, int n_elems, int idx = 0) {
        ref_class = RefClass::Vector;
        obj = o;
        n_elements = n_elems;
        index = idx;
    }

    // Symbol reference
    NrnRef(Symbol* s, const std::string& n = "") {
        ref_class = RefClass::Symbol;
        sym = s;
        name = n;
        n_elements = 1;
    }

    // Range variable reference
    NrnRef(Symbol* s, Section* sc, double xx, const std::string& n = "") {
        ref_class = RefClass::RangeVar;
        sym = s;
        sec = sc;
        x = xx;
        name = n;
        n_elements = 1;
    }

    // ObjectProp reference
    NrnRef(Object* o, const std::string& n = "", int idx = -1) {
        ref_class = RefClass::ObjectProp;
        obj = o;
        name = n;
        index = idx;
        n_elements = 1;
    }

    // Raw pointer reference (default, for backward compatibility)
    NrnRef(size_t size) {
        ref_class = RefClass::Unknown;
        n_elements = size;
    }

    NrnRef() = default;
};

template <typename... Args>
std::tuple<Args...> extractParams(const mxArray* prhs[], int offset) {
    return {}; 
}


template <>
std::tuple<int, double> extractParams<int, double>(const mxArray* prhs[], int offset) {
    int a = static_cast<int>(mxGetScalar(prhs[offset]));
    double b = mxGetScalar(prhs[offset + 1]);
    return {a, b};
}

template <>
std::tuple<std::string> extractParams<std::string>(const mxArray* prhs[], int offset) {
    std::string str = getStringFromMxArray(prhs[offset]);
    return str;
}

template <>
std::tuple<double> extractParams<double>(const mxArray* prhs[], int offset) {
    return {mxGetScalar(prhs[offset])};
}

template <>
std::tuple<std::string, int> extractParams<std::string, int>(const mxArray* prhs[], int offset) {
    return {
        getStringFromMxArray(prhs[offset]),
        static_cast<int>(mxGetScalar(prhs[offset+1]))
    };
}


void nrn_section_new(const mxArray* prhs[], mxArray* plhs[]) {
    auto [name] = extractParams<std::string>(prhs, 1);
    Section* sec = nrn_section_new_(name.c_str());
    // TODO: return the section* by casting to uint64
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(sec);
}

void nrn_hoc_call(const mxArray* prhs[], mxArray* plhs[]) {
    auto [command] = extractParams<std::string>(prhs, 1);
    nrn_hoc_call_(command.c_str());
}

void nrn_double_push(const mxArray* prhs[], mxArray* plhs[]) {
    auto [x] = extractParams<double>(prhs, 1);
    nrn_double_push_(x);
}

void nrn_double_pop(const mxArray* prhs[], mxArray* plhs[]) {
    double result = nrn_double_pop_();
    plhs[0] = mxCreateDoubleScalar(result);
}

void get_nrn_functions(const mxArray* prhs[], mxArray* plhs[]) {
    // Retrieve the global and top-level symbol tables
    auto global_symtable = nrn_global_symbol_table_();
    auto top_level_symtable = nrn_top_level_symbol_table_();
    std::string result;

    // Iterate over both symbol tables
    for (auto symtable : {global_symtable, top_level_symtable}) {
        // Create an iterator for the current symbol table
        auto iter = nrn_symbol_table_iterator_new_(symtable);

        // Loop through all symbols in the table
        while (!nrn_symbol_table_iterator_done_(iter)) {
            // Get symbol
            Symbol* sym = nrn_symbol_table_iterator_next_(iter);

            // Retrieve the symbol name and its type/subtype
            const char* name = nrn_symbol_name_(sym);
            int type = nrn_symbol_type_(sym);
            int subtype = nrn_symbol_subtype_(sym);

            // Append the symbol information to the result string
            result += std::string(name) + ":" + std::to_string(type) + "-" + std::to_string(subtype) + ";";
        }

        // Free the iterator after use
        nrn_symbol_table_iterator_free_(iter);
    }

    // Return the result as a MATLAB string
    plhs[0] = mxCreateString(result.c_str());
}

void nrn_symbol_nrnref(const mxArray* prhs[], mxArray* plhs[]) {
    // Get the symbol name from the first argument
    std::string sym_name = getStringFromMxArray(prhs[1]);
    Symbol* sym = nrn_symbol_(sym_name.c_str());

    // Error if symbol not found in symbol table
    if (!sym) {
        mexErrMsgIdAndTxt("nrn_symbol_nrnref:SymbolNotFound", "Symbol '%s' not found in symbol table.", sym_name.c_str());
        return;
    }

    // If not an array, return 1
    NrnRef* ref = new NrnRef(sym, sym_name);
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);
}

void nrn_vector_nrnref(const mxArray* prhs[], mxArray* plhs[]) {
    // Get the vector object from the first argument
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    int n = static_cast<int>(mxGetScalar(prhs[2]));
    int index = static_cast<int>(mxGetScalar(prhs[3]));
    Object* vec = reinterpret_cast<Object*>(obj_ptr);

    // Check if the index is valid
    if (index < 0 || index >= n) {
        mexErrMsgIdAndTxt("nrn_vector_nrnref:IndexOutOfBounds", "Index %d out of bounds for vector with %d elements.", index + 1, n);
    }

    // Create a NrnRef for the vector
    NrnRef* ref = new NrnRef(vec, n - index, index);

    // Return the NrnRef as a uint64_t
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);

} 

void nrn_rangevar_nrnref(const mxArray* prhs[], mxArray* plhs[]) {
    // Get the range variable name, section, and x value from the arguments
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    std::string var_name = getStringFromMxArray(prhs[2]);
    Symbol* sym = nrn_symbol_(var_name.c_str());
    double x = mxGetScalar(prhs[3]);

    // Create a NrnRef for the range variable
    NrnRef* ref = new NrnRef(sym, sec, x, var_name);

    // Return the NrnRef as a uint64_t
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);
}

void nrn_pp_property_nrnref(const mxArray* prhs[], mxArray* plhs[]) {
    // Get the object pointer and property name from the arguments
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    std::string prop_name = getStringFromMxArray(prhs[2]);

    // Create a NrnRef for the property
    NrnRef* ref = new NrnRef(obj, prop_name);

    // Return the NrnRef as a uint64_t
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);
}

void nrn_pp_property_array_nrnref(const mxArray* prhs[], mxArray* plhs[]) {
    // Get the object pointer, property name, and index from the arguments
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    std::string prop_name = getStringFromMxArray(prhs[2]);
    int index = static_cast<int>(mxGetScalar(prhs[3]));

    // Create a NrnRef for the property array
    NrnRef* ref = new NrnRef(obj, prop_name, index);

    // Return the NrnRef as a uint64_t
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);
}

void nrnref_property_get(const mxArray* prhs[], mxArray* plhs[]) {
    // Get the NrnRef pointer from the first argument
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);

    int index = static_cast<int>(mxGetScalar(prhs[2]));
    if (index >= ref->n_elements) {
        mexErrMsgIdAndTxt("nrnref_property_get:IndexOutOfBounds", "Index %d out of bounds for symbol with %zu elements.", index+1, ref->n_elements);
    }

    if (ref->index >= 0) {
        // If it's an array property, get the value at the specified index
        double value = nrn_property_array_get_(ref->obj, ref->name.c_str(), ref->index);
        plhs[0] = mxCreateDoubleScalar(value);
        return;
    } else {
        double value = nrn_property_get_(ref->obj, ref->name.c_str());
        plhs[0] = mxCreateDoubleScalar(value);
    }
}

void nrnref_property_set(const mxArray* prhs[], mxArray* plhs[]) {
    // Get the NrnRef pointer and new value from the arguments
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    double new_value = mxGetScalar(prhs[2]);

    int index = static_cast<int>(mxGetScalar(prhs[3]));
    if (index >= ref->n_elements) {
        mexErrMsgIdAndTxt("nrnref_property_set:IndexOutOfBounds", "Index %d out of bounds for symbol with %zu elements.", index+1, ref->n_elements);
    }

    if (ref->index >= 0) {
        // If it's an array property, set the value at the specified index
        nrn_property_array_set_(ref->obj, ref->name.c_str(), ref->index, new_value);
        return;
    } else {
        nrn_property_set_(ref->obj, ref->name.c_str(), new_value);
    }
}



void nrnref_symbol_push(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    nrn_symbol_push_(ref->sym);
}

void nrnref_vector_push(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    double* data = nrn_vector_data_(ref->obj);
    if (ref->index < 0 || ref->index >= static_cast<int>(ref->n_elements + ref->index)) {
        mexErrMsgIdAndTxt("nrnref_vector_push:IndexOutOfBounds", "Index %d out of bounds for vector with %zu elements.", ref->index + 1, ref->n_elements);
    }
    nrn_double_ptr_push_(data + ref->index);
}

void nrnref_rangevar_push(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    nrn_rangevar_push_(ref->sym, ref->sec, ref->x);
}

void nrnref_property_push(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    if (ref->index >= 0) {
        // If it's an array property, push the value at the specified index
        nrn_property_array_push_(ref->obj, ref->name.c_str(), ref->index);
        return;
    } else {
        nrn_property_push_(ref->obj, ref->name.c_str());
    }
}

// Function to be called through hoc to run arbitrary matlab code
// passed as string argument.
void nrnmatlab() {
    std::string command = hoc_gargstr_(1);
    char* command_c = const_cast<char*>(command.c_str());

    int status = mexEvalString(command_c);

    hoc_ret_();
    nrn_double_push_(status);
}

// Register nrnmatlab function in hoc.
void setup_nrnmatlab(const mxArray* prhs[], mxArray* plhs[]) {
    nrn_register_function_(nrnmatlab, "nrnmatlab", 280);
}

// Used as hoc function with void return type and instance_id: string.
// Calls matlab function defined in static dictionary with key instance_id.
void finitialize_callback() {
    std::string instance_id = hoc_gargstr_(1);
    std::string command = "neuron.FInitializeHandler.handlers(" + instance_id + ")";
    char* command_c = const_cast<char*>(command.c_str());

    mexEvalString(command_c);

    hoc_ret_();
    nrn_double_push_(0);
}

void create_FInitializeHandler(const mxArray* prhs[], mxArray* plhs[]) {
    int type = static_cast<int>(mxGetScalar(prhs[1]));
    std::string func_name = getStringFromMxArray(prhs[2]);
    std::string instance_id = getStringFromMxArray(prhs[3]);

    // Register the callback in hoc
    nrn_register_function_(finitialize_callback, func_name.c_str(), 280);

    // Create hoc command for calling the callback with instance_id
    std::string command = func_name + "(\"" + instance_id + "\")";
    char* command_c = const_cast<char*>(command.c_str());

    // Register FInitializeHandler object
    // calling the constructor with (type, command_c)
    int n_args = 2;
    nrn_double_push_(type);
    nrn_str_push_(&command_c);
    auto ps = nrn_object_new_(nrn_symbol_("FInitializeHandler"), n_args);
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ps);
}


void nrn_function_call(const mxArray* prhs[], mxArray* plhs[]) {
    auto [name, narg] = extractParams<std::string, int>(prhs, 1);
    auto sym = nrn_symbol_(name.c_str());
    nrn_function_call_(sym, narg);
}

void nrn_object_new(const mxArray* prhs[], mxArray* plhs[]) {
    auto [name, narg] = extractParams<std::string, int>(prhs, 1);
    auto sym = nrn_symbol_(name.c_str());
    Object* obj = nrn_object_new_(sym, narg);
    // Return the Object* by casting to uint64
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(obj);
}

void nrn_object_unref(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    nrn_object_unref_(obj);
}

void get_class_methods(const mxArray* prhs[], mxArray* plhs[]) {
    auto [class_name] = extractParams<std::string>(prhs, 1);
    auto sym = nrn_symbol_(class_name.c_str());
    Symlist* table = nrn_symbol_table_(sym);
    std::string result;

    // Iterate over the symbol table
    auto iter = nrn_symbol_table_iterator_new_(table);

    while (!nrn_symbol_table_iterator_done_(iter)) {
        Symbol* sym = nrn_symbol_table_iterator_next_(iter);
        result += std::string(nrn_symbol_name_(sym)) + ":" + std::to_string(nrn_symbol_type_(sym)) + "-" + std::to_string(nrn_symbol_subtype_(sym)) + ";";
    }

    nrn_symbol_table_iterator_free_(iter);

    // Return the result as a MATLAB string
    plhs[0] = mxCreateString(result.c_str());
}

void nrn_class_name(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    const char* class_name = nrn_class_name_(obj);
    plhs[0] = mxCreateString(class_name);
}

void nrn_method_symbol(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    auto [method_name] = extractParams<std::string>(prhs, 2);
    Symbol* method_sym = nrn_method_symbol_(obj, method_name.c_str());
    // Return the Symbol* by casting to uint64
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(method_sym);
}

void nrn_hoc_call_ob_proc(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    auto sym_ptr = static_cast<uint64_t>(mxGetScalar(prhs[2]));
    Symbol* sym = reinterpret_cast<Symbol*>(sym_ptr);
    auto [narg] = extractParams<int>(prhs, 3);
    hoc_call_ob_proc_(obj, sym, narg);
}

void nrn_get_value(const mxArray* prhs[], mxArray* plhs[]) {
    // Get string name
    std::string propname = getStringFromMxArray(prhs[1]);

    // Lookup symbol in top-level HOC context
    Symbol* sym = nrn_symbol_(propname.c_str());

    if (nrn_symbol_subtype_(sym) == 1) {
        // If subtype is 2, cast to int* and return as int scalar
        int* int_ptr = reinterpret_cast<int*>(nrn_symbol_dataptr_(sym));
        plhs[0] = mxCreateDoubleScalar(static_cast<double>(*int_ptr));
    } else {
        // Otherwise, treat as double
        double* value_ptr = nrn_symbol_dataptr_(sym);
        plhs[0] = mxCreateDoubleScalar(*value_ptr);
    }
}

void nrn_set_value(const mxArray* prhs[], mxArray* plhs[]) {
    // Extract arguments
    std::string propname = getStringFromMxArray(prhs[1]);
    double new_value = mxGetScalar(prhs[2]);

    // Lookup symbol
    Symbol* sym = nrn_symbol_(propname.c_str());

    if (nrn_symbol_subtype_(sym) == 1) {
        // If subtype is 2, cast to int* and write new value as int
        int* int_ptr = reinterpret_cast<int*>(nrn_symbol_dataptr_(sym));
        *int_ptr = static_cast<int>(new_value);
    } else {
        // Otherwise, treat as double
        double* value_ptr = nrn_symbol_dataptr_(sym);
        *value_ptr = new_value;
    }
}

void nrn_method_call(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    auto sym_ptr = static_cast<uint64_t>(mxGetScalar(prhs[2]));
    Symbol* method_sym = reinterpret_cast<Symbol*>(sym_ptr);
    int narg = (int) mxGetScalar(prhs[3]);
    nrn_method_call_(obj, method_sym, narg);
}

void nrn_vector_data(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* vec = reinterpret_cast<Object*>(obj_ptr);
    int len = static_cast<int>(mxGetScalar(prhs[2]));
    double* data = nrn_vector_data_(vec);
    plhs[0] = mxCreateDoubleMatrix(1, len, mxREAL);
    std::memcpy(mxGetPr(plhs[0]), data, len * sizeof(double));
}

void nrn_vector_data_ref(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* vec = reinterpret_cast<Object*>(obj_ptr);
    double* data = nrn_vector_data_(vec);
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(data);
}

void nrn_section_pop(const mxArray* prhs[], mxArray* plhs[]) {
    nrn_section_pop_();
}

void nrn_pop_str(const mxArray* prhs[], mxArray* plhs[]) {
    char** result = nrn_pop_str_();
    plhs[0] = mxCreateString(*result);
}

void nrn_object_pop(const mxArray* prhs[], mxArray* plhs[]) {
    Object* obj = nrn_object_pop_();
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(obj);
}

void nrn_str_push(const mxArray* prhs[], mxArray* plhs[]) {
    // This is a memory leak and we can only have one string at a time on the stack
    // Allocate a static buffer to hold the string pointer
    static char* str = nullptr;
    static std::string temp_str;
    temp_str = getStringFromMxArray(prhs[1]);
    str = const_cast<char*>(temp_str.c_str());
    nrn_str_push_(&str);
    // Do not call mxFree(str); here!
}

void nrn_object_push(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    nrn_object_push_(obj);
}

// void nrn_double_ptr_push(const mxArray* prhs[], mxArray* plhs[]) {
//     auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
//     NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
//     double* ptr = ref->ref;
//     mexPrintf("ptr: %p\n", ptr);
//     nrn_double_ptr_push_(ptr);
// }

void nrn_section_list(const mxArray* prhs[], mxArray* plhs[]) {
    nrn_Item* allsec = nrn_allsec_();
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(allsec);
}

void nrn_sectionlist_data(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    nrn_Item* item = nrn_sectionlist_data_(obj);
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(item);
}

void nrn_section_push(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    nrn_section_push_(sec);
}

void nrn_mechanism_insert(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    auto mech_name = getStringFromMxArray(prhs[2]);
    const Symbol* mechanism = nrn_symbol_(mech_name.c_str());
    nrn_mechanism_insert_(sec, mechanism);
}

void nrn_rangevar_get(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    auto sym_name = getStringFromMxArray(prhs[2]);
    Symbol* sym = nrn_symbol_(sym_name.c_str());
    auto [x] = extractParams<double>(prhs, 3);
    double result = nrn_rangevar_get_(sym, sec, x);
    plhs[0] = mxCreateDoubleScalar(result);
}

// void nrn_get_ref(const mxArray* prhs[], mxArray* plhs[]) {
//     auto value_ptr = reinterpret_cast<double*>(static_cast<uint64_t>(mxGetScalar(prhs[1])));
//     NrnRef* ref = nullptr;
//     size_t length = static_cast<size_t>(mxGetScalar(prhs[2]));
//     ref = new NrnRef(value_ptr, length);
//     mexPrintf("value_ptr: %p\n", value_ptr);
//     plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
//     *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);
// }

void nrn_section_connect(const mxArray* prhs[], mxArray* plhs[]) {
    auto child_sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* child_sec = reinterpret_cast<Section*>(child_sec_ptr);
    auto [child_x] = extractParams<double>(prhs, 2);
    auto parent_sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[3]));
    Section* parent_sec = reinterpret_cast<Section*>(parent_sec_ptr);
    auto [parent_x] = extractParams<double>(prhs, 4);
    nrn_section_connect_(child_sec, child_x, parent_sec, parent_x);
}

void nrn_section_length_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    auto [length] = extractParams<double>(prhs, 2);
    nrn_section_length_set_(sec, length);
}

void nrn_section_length_get(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    double length = nrn_section_length_get_(sec);
    plhs[0] = mxCreateDoubleScalar(length);
}

void nrn_secname(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    const char* name = nrn_secname_(sec);
    plhs[0] = mxCreateString(name);
}

void nrn_nseg_get(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    int nseg = nrn_nseg_get_(sec);
    plhs[0] = mxCreateDoubleScalar(static_cast<double>(nseg));
}

void nrn_nseg_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    int nseg = (int) mxGetScalar(prhs[2]);
    nrn_nseg_set_(sec, nseg);
}

void nrn_segment_diam_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    auto [x, diam] = extractParams<double, double>(prhs, 2);
    nrn_segment_diam_set_(sec, x, diam);
}

void nrn_section_diam_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    double diam = mxGetScalar(prhs[2]);

    int nseg = nrn_nseg_get_(sec);
    for (int i = 0; i < nseg; ++i) {
        double x = (i + 0.5) / nseg;  // center of each segment
        nrn_segment_diam_set_(sec, x, diam);
    }
}

void nrn_section_diam_get(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);

    // Always use x=0.5 (center of section), just like HOC's default
    double x = 0.5;
    double diam = nrn_segment_diam_get_(sec, x);
    plhs[0] = mxCreateDoubleScalar(diam);
}


void nrn_property_get(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    auto [name] = extractParams<std::string>(prhs, 2);
    const char* obj_name = nrn_class_name_(obj);
    double result = nrn_property_get_(obj, name.c_str());
    plhs[0] = mxCreateDoubleScalar(result);
}

void nrn_property_array_get(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    auto [name, index] = extractParams<std::string, int>(prhs, 2);
    double result = nrn_property_array_get_(obj, name.c_str(), index);
    plhs[0] = mxCreateDoubleScalar(result);
}

void nrn_property_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    auto [name] = extractParams<std::string>(prhs, 2);
    double value = mxGetScalar(prhs[3]);
    nrn_property_set_(obj, name.c_str(), value);
}

void nrn_property_array_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    auto name = getStringFromMxArray(prhs[2]);
    Symbol* sym = nrn_method_symbol_(obj, name.c_str());
    double value = mxGetScalar(prhs[3]);
    int index = (int) mxGetScalar(prhs[4]);
    int max_index = nrn_symbol_array_length_(sym);
    if (index >= max_index) {
        mexErrMsgIdAndTxt("nrn_property_array_set:IndexOutOfBounds", "Index %d out of bounds for symbol with %zu elements.", index+1, nrn_symbol_array_length_(sym));
    }
    nrn_property_array_set_(obj, name.c_str(), index, value);
}

// void nrn_get_value_ref(const mxArray* prhs[], mxArray* plhs[]) {
//     // Get string name
//     std::string propname = getStringFromMxArray(prhs[1]);

//     // Lookup symbol in top-level HOC context
//     Symbol* sym = nrn_symbol_(propname.c_str());

//     if (nrn_symbol_subtype_(sym) == 1) {
//         // If subtype is 2, cast to int* and create NrnRef
//         int* int_ptr = reinterpret_cast<int*>(nrn_symbol_dataptr_(sym));
//         NrnRef* ref = new NrnRef(reinterpret_cast<double*>(int_ptr));
//         plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
//         *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);
//     } else {
//         // Otherwise, treat as double and create NrnRef
//         double* value_ptr = nrn_symbol_dataptr_(sym);
//         NrnRef* ref = new NrnRef(value_ptr);
//         plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
//         *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);
//     }
// }

std::vector<double> get_segment_arc(Section* sec, double low, double high, double ns, std::vector<std::vector<double>>& pt3d) {

    auto segment_arc = std::vector<double>();

    segment_arc.push_back(low);

    for (size_t i = 0; i < ns; i++) {
        double arc = pt3d[3][i];

        if (arc > low && arc < high) {
            segment_arc.push_back(arc);
        }
    }

    segment_arc.push_back(high);

    return segment_arc;
}

double linearly_interpolate(double a, double b, double f) {
    return a + f * (b - a);
}

double interpolate_arrays(std::vector<double> xs, std::vector<double> ys, double v) {
    auto xs_iter = xs.begin() + 1;

    while(v > *xs_iter) {
        xs_iter++;
    }

    auto a = ys.begin() + ((xs_iter - 1) - xs.begin());
    auto b = ys.begin() + (xs_iter - xs.begin());
    double f = (v - *(xs_iter - 1)) / (*xs_iter - *(xs_iter - 1));

    return linearly_interpolate(*a, *b, f);
}

std::vector<double> get_section_plot_data(Section* sec, ShapePlotInterface* spi) {

    auto result = std::vector<double>();

    size_t n_segments = nrn_nseg_get_(sec);
    double sec_length = nrn_section_length_get_(sec);

    nrn_section_push_(sec);
    nrn_function_call_(nrn_symbol_("n3d"), 0);
    auto ns = nrn_double_pop_();

    std::vector<std::vector<double>> pt3d(5, std::vector<double>(ns, 0.0));
    std::vector<std::string> fields = {"x3d", "y3d", "z3d", "arc3d", "diam3d"};

    for (int i = 0; i < ns; ++i) {
        for (size_t j = 0; j < fields.size(); ++j) {
            nrn_double_push_(i);
            auto field_sym = nrn_symbol_(fields[j].c_str());
            nrn_function_call_(field_sym, 1);
            pt3d[j][i] = nrn_double_pop_();
        }
    }

    auto& xs = pt3d[0];
    auto& ys = pt3d[1];
    auto& zs = pt3d[2];
    auto& arcs = pt3d[3];
    auto& ds = pt3d[4];

    for (size_t i = 0; i < n_segments; i++) {
        double x_lo = (double) i / n_segments;
        double x_hi = (double) (i + 1) / n_segments;
        double x = (double) (i + 0.5) / n_segments;
        x_lo *= sec_length;
        x_hi *= sec_length;

        auto segment_arc = get_segment_arc(sec, x_lo, x_hi, ns, pt3d);

        const char* varname = nrn_get_plotshape_varname_(spi);
        double seg_value = 0.0;
        if (!varname || varname[0] == '\0') {
            // If no variable name is specified, use the section length
            seg_value = std::numeric_limits<double>::quiet_NaN();
        } else {
            // Otherwise, get the value of the specified variable
            seg_value = nrn_rangevar_get_(nrn_symbol_(varname), sec, x);
        }
        

        // Do one initial run
        result.push_back(interpolate_arrays(arcs, xs, segment_arc[0]));
        result.push_back(interpolate_arrays(arcs, xs, segment_arc[1]));
        result.push_back(interpolate_arrays(arcs, ys, segment_arc[0]));
        result.push_back(interpolate_arrays(arcs, ys, segment_arc[1]));
        result.push_back(interpolate_arrays(arcs, zs, segment_arc[0]));
        result.push_back(interpolate_arrays(arcs, zs, segment_arc[1]));
        result.push_back(interpolate_arrays(arcs, ds, segment_arc[0]));
        result.push_back(interpolate_arrays(arcs, ds, segment_arc[1]));
        result.push_back(seg_value);
        // Use initial run and reuse previously calculated values
        for (size_t j = 1; j < segment_arc.size() - 1; j++) {
            result.push_back(result[result.size() - 8]); // xs for segment j
            result.push_back(interpolate_arrays(arcs, xs, segment_arc[j + 1]));
            result.push_back(result[result.size() - 8]); // ys for segment j
            result.push_back(interpolate_arrays(arcs, ys, segment_arc[j + 1]));
            result.push_back(result[result.size() - 8]); // zs for segment j
            result.push_back(interpolate_arrays(arcs, zs, segment_arc[j + 1]));
            result.push_back(result[result.size() - 8]); // ds for segment j
            result.push_back(interpolate_arrays(arcs, ds, segment_arc[j + 1]));
            result.push_back(seg_value);
        }
    }

    return result;
}

void get_plot_data(const mxArray* prhs[], mxArray* plhs[]) {
    auto result = std::vector<double>();

    nrn_Item* my_section_list;
    auto spi_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    ShapePlotInterface* spi = reinterpret_cast<ShapePlotInterface*>(spi_ptr);
    Object* sl = nrn_get_plotshape_section_list_(spi);
    if (sl) {
        my_section_list = nrn_sectionlist_data_(sl);
    } else {
        // no section list specified so use the global all sections list
        my_section_list = nrn_allsec_();
    }

    SectionListIterator* sli = nrn_sectionlist_iterator_new_(my_section_list);
    while (!nrn_sectionlist_iterator_done_(sli)) {
        Section* section = nrn_sectionlist_iterator_next_(sli);
        auto sec_plot_data = get_section_plot_data(section, spi);
        result.insert(result.end(), sec_plot_data.begin(), sec_plot_data.end());
    }
    nrn_sectionlist_iterator_free_(sli);

    plhs[0] = mxCreateDoubleMatrix(1, result.size(), mxREAL);
    std::memcpy(mxGetPr(plhs[0]), result.data(), result.size() * sizeof(double));
}

void nrn_loop_sections(const mxArray* prhs[], mxArray* plhs[]) {
    // Get the section list type (0 for allsec, 1 for specific SectionList)
    int list_type = static_cast<int>(mxGetScalar(prhs[1]));

    SectionListIterator* sli = nullptr;

    if (list_type == 0) {
        // Use allsec
        sli = nrn_sectionlist_iterator_new_(nrn_allsec_());
    } else if (list_type == 1) {
        // Use specific SectionList
        auto seclist_ptr = static_cast<uint64_t>(mxGetScalar(prhs[2]));
        nrn_Item* seclist = reinterpret_cast<nrn_Item*>(seclist_ptr);
        sli = nrn_sectionlist_iterator_new_(seclist);
    }

    // Create a MATLAB array to store section pointers
    std::vector<uint64_t> section_pointers;

    while (!nrn_sectionlist_iterator_done_(sli)) {
        Section* sec = nrn_sectionlist_iterator_next_(sli);
        
        section_pointers.push_back(reinterpret_cast<uint64_t>(sec));
    }

    nrn_sectionlist_iterator_free_(sli);

    // Convert section pointers to MATLAB numeric array
    plhs[0] = mxCreateNumericMatrix(section_pointers.size(), 1, mxUINT64_CLASS, mxREAL);
    std::memcpy(mxGetData(plhs[0]), section_pointers.data(), section_pointers.size() * sizeof(uint64_t));
}

// void nrnref_get_index(const mxArray* prhs[], mxArray* plhs[]) {
//     // Extract the NrnRef pointer from prhs[1]
//     auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
//     NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);

//     // Extract the index from prhs[2]
//     size_t index = static_cast<size_t>(mxGetScalar(prhs[2]));

//     // Get the value at the specified index
//     double value = *(ref->ref + index);
//     plhs[0] = mxCreateDoubleScalar(value);
// }

// void nrnref_get(const mxArray* prhs[], mxArray* plhs[]) {
//     // Extract the NrnRef pointer from prhs[1]
//     auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
//     NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);

//     // Get the value
//     double value = *(ref->ref);
//     plhs[0] = mxCreateDoubleScalar(value);
// }

// void nrnref_set_index(const mxArray* prhs[], mxArray* plhs[]) {
//     // Extract the NrnRef pointer from prhs[1]
//     auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
//     NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);

//     // Extract the value and index from prhs[2] and prhs[3]
//     double value = mxGetScalar(prhs[2]);
//     size_t index = static_cast<size_t>(mxGetScalar(prhs[3]));

//     // Set the value at the specified index
//     try {
//         *(ref->ref + index) = value;
//     } catch (const std::out_of_range& e) {
//         mexErrMsgIdAndTxt("NrnRef:setIndexOutOfBounds", e.what());
//     }
// }

void nrnref_set(const mxArray* prhs[], mxArray* plhs[]) {
    // Extract the NrnRef pointer from prhs[1]
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);

    // Extract the value to set from prhs[2]
    double value = mxGetScalar(prhs[2]);

    // Set the value
    // *(ref->ref) = value;
}

void nrnref_get_n_elements(const mxArray* prhs[], mxArray* plhs[]) {
    // Extract the NrnRef pointer from prhs[1]
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);

    // Return the n_elements field
    plhs[0] = mxCreateDoubleScalar(static_cast<double>(ref->n_elements));
}

void nrnref_get_name(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);

    if (ref->ref_class == NrnRef::RefClass::Vector) {
        // For Vectors, call label function to get the name
        nrn_method_call_(ref->obj, nrn_method_symbol_(ref->obj, "label"), 0);
        char** result = nrn_pop_str_();
        plhs[0] = mxCreateString(*result);
    }
    else {
        plhs[0] = mxCreateString(ref->name.c_str());
    }
}

void nrnref_get_class(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    const char* class_str = "Unknown";
    switch (ref->ref_class) {
        case NrnRef::RefClass::Vector:   class_str = "Vector"; break;
        case NrnRef::RefClass::Symbol:   class_str = "Symbol"; break;
        case NrnRef::RefClass::RangeVar: class_str = "RangeVar"; break;
        case NrnRef::RefClass::ObjectProp:  class_str = "ObjectProp"; break;
        default: break;
    }
    plhs[0] = mxCreateString(class_str);
}

void nrnref_get_symbol(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    if (ref->sym) {
        plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
        *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref->sym);
    } else {
        plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
    }
}

void nrnref_get_section(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    if (ref->sec) {
        plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
        *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref->sec);
    } else {
        plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
    }
}

void nrnref_get_object(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    if (ref->obj) {
        plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
        *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref->obj);
    } else {
        plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
    }
}

void nrnref_set_n_elements(const mxArray* prhs[], mxArray* plhs[]) {
    // Extract the NrnRef pointer from prhs[1]
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);

    // Extract the new n_elements value from prhs[2]
    size_t new_n_elements = static_cast<size_t>(mxGetScalar(prhs[2]));

    // Update the n_elements field
    ref->n_elements = new_n_elements;
}

void nrn_section_is_active(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    bool is_active = nrn_section_is_active_(sec);
    plhs[0] = mxCreateLogicalScalar(is_active);
}

void nrn_rangevar_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    auto sym_name = getStringFromMxArray(prhs[2]);
    Symbol* sym = nrn_symbol_(sym_name.c_str());
    double x = mxGetScalar(prhs[3]);
    double value = mxGetScalar(prhs[4]);
    nrn_rangevar_set_(sym, sec, x, value);
}

void nrn_get_plotshape_interface(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* ps = reinterpret_cast<Object*>(obj_ptr);
    ShapePlotInterface* interface = nrn_get_plotshape_interface_(ps);
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(interface);
}

void nrn_symbol_is_array(const mxArray* prhs[], mxArray* plhs[]) {
    auto sym_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Symbol* sym = reinterpret_cast<Symbol*>(sym_ptr);
    bool is_array = nrn_symbol_is_array_(sym);
    plhs[0] = mxCreateLogicalScalar(is_array);
}

void nrn_get_plotshape_low(const mxArray* prhs[], mxArray* plhs[]) {
    auto spi_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    ShapePlotInterface* spi = reinterpret_cast<ShapePlotInterface*>(spi_ptr);
    float low = nrn_get_plotshape_low_(spi);
    plhs[0] = mxCreateDoubleScalar(static_cast<double>(low));
}

void nrn_get_plotshape_high(const mxArray* prhs[], mxArray* plhs[]) {
    auto spi_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    ShapePlotInterface* spi = reinterpret_cast<ShapePlotInterface*>(spi_ptr);
    float high = nrn_get_plotshape_high_(spi);
    plhs[0] = mxCreateDoubleScalar(static_cast<double>(high));
}

void nrn_symbol_type(const mxArray* prhs[], mxArray* plhs[]) {
    auto sym_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Symbol* sym = reinterpret_cast<Symbol*>(sym_ptr);
    int type = nrn_symbol_type_(sym);
    plhs[0] = mxCreateDoubleScalar(static_cast<double>(type));
}

void nrn_symbol(const mxArray* prhs[], mxArray* plhs[]) {
    auto [name] = extractParams<std::string>(prhs, 1);
    Symbol* sym = nrn_symbol_(name.c_str());
    // Return the Symbol* by casting to uint64
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(sym);
}

void nrn_get_plotshape_varname(const mxArray* prhs[], mxArray* plhs[]) {
    auto spi_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    ShapePlotInterface* spi = reinterpret_cast<ShapePlotInterface*>(spi_ptr);
    const char* varname = nrn_get_plotshape_varname_(spi);
    if (!varname || varname[0] == '\0') {
        varname = "no variable specified";
    }
    plhs[0] = mxCreateString(varname);
}

void nrn_symbol_array_length(const mxArray* prhs[], mxArray* plhs[]) {
    auto sym_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Symbol* sym = reinterpret_cast<Symbol*>(sym_ptr);
    int size = nrn_symbol_array_length_(sym);
    plhs[0] = mxCreateDoubleScalar(static_cast<double>(size));
}

void nrn_section_Ra_get(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    double val = nrn_section_Ra_get_(sec);
    plhs[0] = mxCreateDoubleScalar(val);
}

void nrn_section_Ra_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    double val = mxGetScalar(prhs[2]);
    nrn_section_Ra_set_(sec, val);
}

void nrn_section_rallbranch_get(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    double val = nrn_section_rallbranch_get_(sec);
    plhs[0] = mxCreateDoubleScalar(val);
}

void nrn_section_rallbranch_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    double val = mxGetScalar(prhs[2]);
    nrn_section_rallbranch_set_(sec, val);
}

void nrn_rangevar_push(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    auto sym_name = getStringFromMxArray(prhs[2]);
    Symbol* sym = nrn_symbol_(sym_name.c_str());
    double x = mxGetScalar(prhs[3]);
    nrn_rangevar_push_(sym, sec, x);
}

void nrn_double_ptr_pop(const mxArray* prhs[], mxArray* plhs[]) {
    double* ptr = nrn_double_ptr_pop_();
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ptr);
}

void nrn_symbol_dataptr(const mxArray* prhs[], mxArray* plhs[]) {
    auto [name] = extractParams<std::string>(prhs, 1);
    Symbol* sym = nrn_symbol_(name.c_str());
    double* dataptr = nrn_symbol_dataptr_(sym);
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(dataptr);
}

void nrnref_symbol_get(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    int index = static_cast<int>(mxGetScalar(prhs[2]));
    if (index >= ref->n_elements) {
        mexErrMsgIdAndTxt("nrnref_symbol_get:IndexOutOfBounds", "Index %d out of bounds for symbol with %zu elements.", index+1, ref->n_elements);
    }
    double* dataptr = nrn_symbol_dataptr_(ref->sym);
    plhs[0] = mxCreateDoubleScalar(*(dataptr + index));
}

void nrnref_symbol_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    double value = mxGetScalar(prhs[2]);
    int index = static_cast<int>(mxGetScalar(prhs[3]));
    if (index >= ref->n_elements) {
        mexErrMsgIdAndTxt("nrnref_symbol_set:IndexOutOfBounds", "Index %d out of bounds for symbol with %zu elements.", index+1, ref->n_elements);
    }
    double* dataptr = nrn_symbol_dataptr_(ref->sym);
    *(dataptr + index) = value;
}  

void nrnref_vector_get(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    int index = static_cast<int>(mxGetScalar(prhs[2])) + ref->index;
    if (index >= ref->n_elements + ref->index || index - ref->index < 0) {
        mexErrMsgIdAndTxt("nrnref_vector_get:IndexOutOfBounds", "Index %d out of bounds for vector with %zu elements.", index+1-ref->index, ref->n_elements);
    }
    double* data = nrn_vector_data_(ref->obj);
    plhs[0] = mxCreateDoubleScalar(*(data + index));
}

void nrnref_vector_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    double value = mxGetScalar(prhs[2]);
    int index = static_cast<int>(mxGetScalar(prhs[3])) + ref->index;
    if (index >= ref->n_elements + ref->index || index - ref->index < 0) {
        mexErrMsgIdAndTxt("nrnref_vector_set:IndexOutOfBounds", "Index %d out of bounds for vector with %zu elements.", index+1-ref->index, ref->n_elements);
    }
    double* data = nrn_vector_data_(ref->obj);
    *(data + index) = value;
}

void nrnref_rangevar_get(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    int index = static_cast<int>(mxGetScalar(prhs[2]));
    if (index >= ref->n_elements) {
        mexErrMsgIdAndTxt("nrnref_rangevar_get:IndexOutOfBounds", "Index %d out of bounds for range variable with %zu elements.", index+1, ref->n_elements);
    }
    double value = nrn_rangevar_get_(ref->sym, ref->sec, ref->x);
    plhs[0] = mxCreateDoubleScalar(value);
}

void nrnref_rangevar_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto ref_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    NrnRef* ref = reinterpret_cast<NrnRef*>(ref_ptr);
    double value = mxGetScalar(prhs[2]);
    int index = static_cast<int>(mxGetScalar(prhs[3]));
    if (index >= ref->n_elements) {
        mexErrMsgIdAndTxt("nrnref_rangevar_set:IndexOutOfBounds", "Index %d out of bounds for range variable with %zu elements.", index+1, ref->n_elements);
    }
    nrn_rangevar_set_(ref->sym, ref->sec, ref->x, value);
}

// void nrn_get_ref_from_symbol(const mxArray* prhs[], mxArray* plhs[]) {
//     auto [name] = extractParams<std::string>(prhs, 1);
//     size_t length = static_cast<size_t>(mxGetScalar(prhs[2]));
//     Symbol* sym = nrn_symbol_(name.c_str());
//     double* ptr = nrn_symbol_dataptr_(sym);
//     NrnRef* ref = new NrnRef(ptr, length);
//     plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
//     *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);
// }

void nrn_symbol_push(const mxArray* prhs[], mxArray* plhs[]) {
    auto [name] = extractParams<std::string>(prhs, 1);
    Symbol* sym = nrn_symbol_(name.c_str());
    nrn_symbol_push_(sym);
}

void nrn_section_ref(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    nrn_section_ref_(sec);
}

void nrn_section_unref(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    nrn_section_unref_(sec);
}

void nrn_cas(const mxArray* prhs[], mxArray* plhs[]) {
    Section* sec = nrn_cas_();
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(sec);
}

void nrn_sectionlist_iterator_new(const mxArray* prhs[], mxArray* plhs[]) {
    auto item_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    nrn_Item* item = reinterpret_cast<nrn_Item*>(item_ptr);
    SectionListIterator* iter = nrn_sectionlist_iterator_new_(item);
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(iter);
}

void nrn_sectionlist_iterator_free(const mxArray* prhs[], mxArray* plhs[]) {
    auto iter_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    SectionListIterator* iter = reinterpret_cast<SectionListIterator*>(iter_ptr);
    nrn_sectionlist_iterator_free_(iter);
}

void nrn_sectionlist_iterator_next(const mxArray* prhs[], mxArray* plhs[]) {
    auto iter_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    SectionListIterator* iter = reinterpret_cast<SectionListIterator*>(iter_ptr);
    Section* sec = nrn_sectionlist_iterator_next_(iter);
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(sec);
}

void nrn_sectionlist_iterator_done(const mxArray* prhs[], mxArray* plhs[]) {
    auto iter_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    SectionListIterator* iter = reinterpret_cast<SectionListIterator*>(iter_ptr);
    int done = nrn_sectionlist_iterator_done_(iter);
    plhs[0] = mxCreateLogicalScalar(done != 0);
}

void nrn_prop_exists(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    const Object* obj = reinterpret_cast<const Object*>(obj_ptr);
    bool result = nrn_prop_exists_(obj);
    plhs[0] = mxCreateLogicalScalar(result);
}



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (!neuron_handle) {
        #ifndef _WIN32
        // Load the wrapper library first
        DLL_HANDLE wrapper_handle = DLL_LOAD("libmodlreg.dylib");
        if (!wrapper_handle) {
            mexErrMsgIdAndTxt("load_neuron:loadFailure", "Failed to load libmodlreg.dylib: %s", DLL_ERROR());
            return;
        }
        #endif
    
        // Load the NEURON library next
        neuron_handle = DLL_LOAD("/usr/local/lib/libnrniv.dylib");
        if (!neuron_handle) {
            mexErrMsgIdAndTxt("load_neuron:loadFailure", "Failed to load libnrniv.dylib: %s", DLL_ERROR());
            //DLL_FREE(wrapper_handle);  // Clean up before returning
            //DLL_FREE(neuron_handle);
            return;
        }
    
        static std::array<const char*, 4> argv = {"NEURON", "-nogui", "-nopython", nullptr};
        auto nrn_init = (int (*)(int, const char**)) DLL_GET_PROC(neuron_handle, "nrn_init");
    
        if (nrn_init) {
            nrn_init(3, argv.data());
        } else {
            mexErrMsgIdAndTxt("load_neuron:functionNotFound", "Function nrn_init not found: %s", DLL_ERROR());
            //DLL_FREE(wrapper_handle);
            //DLL_FREE(neuron_handle);
            return;
        }
    
        auto nrn_stdout_redirect = (void (*)(int (*)(int, char*))) DLL_GET_PROC(neuron_handle, "nrn_stdout_redirect");
        if (nrn_stdout_redirect) {
            nrn_stdout_redirect(mlprint);
        } else {
            mexErrMsgIdAndTxt("load_neuron:functionNotFound", "Function nrn_stdout_redirect not found: %s", DLL_ERROR());
            //DLL_FREE(wrapper_handle);
            //DLL_FREE(neuron_handle);
            return;
        }

        // setup the mappings
        nrn_section_new_ = (Section* (*)(char const*)) DLL_GET_PROC(neuron_handle, "nrn_section_new");
        function_map["nrn_section_new"] = nrn_section_new;
        nrn_hoc_call_ = (void(*)(const char*)) DLL_GET_PROC(neuron_handle, "nrn_hoc_call");
        function_map["nrn_hoc_call"] = nrn_hoc_call;
        nrn_double_push_ = (void(*)(double)) DLL_GET_PROC(neuron_handle, "nrn_double_push");
        function_map["nrn_double_push"] = nrn_double_push;
        function_map["get_nrn_functions"] = get_nrn_functions;
        function_map["setup_nrnmatlab"] = setup_nrnmatlab;
        nrn_global_symbol_table_ = (Symlist*(*)(void)) DLL_GET_PROC(neuron_handle, "nrn_global_symbol_table");
        nrn_top_level_symbol_table_ = (Symlist*(*)(void)) DLL_GET_PROC(neuron_handle, "nrn_top_level_symbol_table");
        nrn_symbol_table_iterator_new_ = (SymbolTableIterator* (*)(Symlist*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_table_iterator_new");
        nrn_symbol_table_iterator_free_ = (void (*)(SymbolTableIterator*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_table_iterator_free");
        nrn_symbol_table_iterator_next_ = (Symbol* (*)(SymbolTableIterator*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_table_iterator_next");
        nrn_symbol_table_iterator_done_ = (int (*)(SymbolTableIterator*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_table_iterator_done");
        nrn_sectionlist_iterator_new_ = (SectionListIterator* (*)(nrn_Item*)) DLL_GET_PROC(neuron_handle, "nrn_sectionlist_iterator_new");
        nrn_sectionlist_iterator_free_ = (void (*)(SectionListIterator*)) DLL_GET_PROC(neuron_handle, "nrn_sectionlist_iterator_free");
        nrn_sectionlist_iterator_next_ = (Section* (*)(SectionListIterator*)) DLL_GET_PROC(neuron_handle, "nrn_sectionlist_iterator_next");
        nrn_sectionlist_iterator_done_ = (int (*)(SectionListIterator*)) DLL_GET_PROC(neuron_handle, "nrn_sectionlist_iterator_done");
        function_map["nrn_loop_sections"] = nrn_loop_sections;
        nrn_symbol_ = (Symbol* (*)(char const* const)) DLL_GET_PROC(neuron_handle, "nrn_symbol");
        nrn_symbol_type_ = (int (*)(const Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_type");
        nrn_symbol_subtype_ = (int (*)(const Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_subtype");
        nrn_symbol_name_ = (char const* (*)(const Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_name");
        hoc_install_ = (Symbol* (*)(const char*, int, double, Symlist**)) DLL_GET_PROC(neuron_handle, "hoc_install");
        nrn_register_function_ = (void (*)(void (*)(), const char*, int)) DLL_GET_PROC(neuron_handle, "nrn_register_function");
        hoc_gargstr_ = (char* (*)(int)) DLL_GET_PROC(neuron_handle, "_Z11hoc_gargstri");  // TODO get rid of name mangling
        hoc_ret_ = (void (*)(void)) DLL_GET_PROC(neuron_handle, "_Z7hoc_retv");  // TODO get rid of name mangling
        hoc_pushx_ = (void (*)(double)) DLL_GET_PROC(neuron_handle, "hoc_pushx");
        nrn_function_call_ = (void(*)(Symbol*,int)) DLL_GET_PROC(neuron_handle, "nrn_function_call");
        function_map["nrn_function_call"] = nrn_function_call;
        nrn_double_pop_ = (double (*)(void)) DLL_GET_PROC(neuron_handle, "nrn_double_pop");
        function_map["nrn_double_pop"] = nrn_double_pop;
        nrn_object_new_ = (Object* (*)(Symbol*, int)) DLL_GET_PROC(neuron_handle, "nrn_object_new");
        function_map["nrn_object_new"] = nrn_object_new;
        nrn_object_unref_ = (void (*)(Object*)) DLL_GET_PROC(neuron_handle, "nrn_object_unref");
        function_map["nrn_object_unref"] = nrn_object_unref;
        nrn_symbol_table_ = (Symlist* (*)(Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_table");
        nrn_class_name_ = (char const* (*)(const Object*)) DLL_GET_PROC(neuron_handle, "nrn_class_name");
        function_map["nrn_class_name"] = nrn_class_name;
        function_map["get_class_methods"] = get_class_methods;
        nrn_method_symbol_ = (Symbol* (*)(Object*, char const* const)) DLL_GET_PROC(neuron_handle, "nrn_method_symbol");
        function_map["nrn_method_symbol"] = nrn_method_symbol;
        hoc_call_ob_proc_ = (void (*)(Object*, Symbol*, int)) DLL_GET_PROC(neuron_handle, "hoc_call_ob_proc");
        function_map["nrn_hoc_call_ob_proc"] = nrn_hoc_call_ob_proc;
        function_map["nrn_get_value"] = nrn_get_value;
        nrn_symbol_dataptr_ = (double* (*)(Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_dataptr");
        function_map["nrn_set_value"] = nrn_set_value;
        nrn_method_call_ = (void (*)(Object*, Symbol*, int)) DLL_GET_PROC(neuron_handle, "nrn_method_call");
        function_map["nrn_method_call"] = nrn_method_call;
        nrn_vector_data_ = (double* (*)(Object*)) DLL_GET_PROC(neuron_handle, "nrn_vector_data");
        function_map["nrn_vector_data"] = nrn_vector_data;
        nrn_section_pop_ = (void (*)(void)) DLL_GET_PROC(neuron_handle, "nrn_section_pop");
        function_map["nrn_section_pop"] = nrn_section_pop;
        nrn_pop_str_ = (char** (*)(void)) DLL_GET_PROC(neuron_handle, "nrn_pop_str");
        function_map["nrn_pop_str"] = nrn_pop_str;
        nrn_object_pop_ = (Object* (*)(void)) DLL_GET_PROC(neuron_handle, "nrn_object_pop");
        function_map["nrn_object_pop"] = nrn_object_pop;
        nrn_str_push_ = (void (*)(char**)) DLL_GET_PROC(neuron_handle, "nrn_str_push");
        function_map["nrn_str_push"] = nrn_str_push;
        nrn_object_push_ = (void (*)(Object*)) DLL_GET_PROC(neuron_handle, "nrn_object_push");
        function_map["nrn_object_push"] = nrn_object_push;
        nrn_double_ptr_push_ = (void (*)(double*)) DLL_GET_PROC(neuron_handle, "nrn_double_ptr_push");
        // function_map["nrn_double_ptr_push"] = nrn_double_ptr_push;
        nrn_allsec_ = (nrn_Item* (*)(void)) DLL_GET_PROC(neuron_handle, "nrn_allsec");
        function_map["nrn_section_list"] = nrn_section_list;
        nrn_sectionlist_data_ = (nrn_Item* (*)(Object*)) DLL_GET_PROC(neuron_handle, "nrn_sectionlist_data");
        function_map["nrn_sectionlist_data"] = nrn_sectionlist_data;
        nrn_section_push_ = (void (*)(Section*)) DLL_GET_PROC(neuron_handle, "nrn_section_push");
        function_map["nrn_section_push"] = nrn_section_push;
        nrn_section_new_ = (Section* (*)(char const*)) DLL_GET_PROC(neuron_handle, "nrn_section_new");
        function_map["nrn_section_new"] = nrn_section_new;
        nrn_mechanism_insert_ = (void (*)(Section*, const Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_mechanism_insert");
        function_map["nrn_mechanism_insert"] = nrn_mechanism_insert;
        nrn_rangevar_get_ = (double (*)(Symbol*, Section*, double)) DLL_GET_PROC(neuron_handle, "nrn_rangevar_get");
        function_map["nrn_rangevar_get"] = nrn_rangevar_get;
        nrn_section_connect_ = (void (*)(Section*, double, Section*, double)) DLL_GET_PROC(neuron_handle, "nrn_section_connect");
        function_map["nrn_section_connect"] = nrn_section_connect;
        nrn_section_length_set_ = (void (*)(Section*, double)) DLL_GET_PROC(neuron_handle, "nrn_section_length_set");
        function_map["nrn_section_length_set"] = nrn_section_length_set;
        nrn_section_length_get_ = (double (*)(Section*)) DLL_GET_PROC(neuron_handle, "nrn_section_length_get");
        function_map["nrn_section_length_get"] = nrn_section_length_get;
        nrn_secname_ = (const char* (*)(Section*)) DLL_GET_PROC(neuron_handle, "nrn_secname");
        function_map["nrn_secname"] = nrn_secname;
        nrn_nseg_get_ = (int (*)(Section const*)) DLL_GET_PROC(neuron_handle, "nrn_nseg_get");
        function_map["nrn_nseg_get"] = nrn_nseg_get;
        nrn_nseg_set_ = (void (*)(Section*, const int)) DLL_GET_PROC(neuron_handle, "nrn_nseg_set");
        function_map["nrn_nseg_set"] = nrn_nseg_set;
        nrn_segment_diam_set_ = (void (*)(Section*, const double, const double)) DLL_GET_PROC(neuron_handle, "nrn_segment_diam_set");
        function_map["nrn_segment_diam_set"] = nrn_segment_diam_set;
        function_map["nrn_section_diam_set"] = nrn_section_diam_set;
        nrn_segment_diam_get_ = (double (*)(Section* const, const double)) DLL_GET_PROC(neuron_handle, "nrn_segment_diam_get");
        function_map["nrn_section_diam_get"] = nrn_section_diam_get;
        nrn_property_get_ = (double (*)(Object const*, const char*)) DLL_GET_PROC(neuron_handle, "nrn_property_get");
        function_map["nrn_property_get"] = nrn_property_get;
        nrn_property_array_get_ = (double (*)(Object const*, const char*, int)) DLL_GET_PROC(neuron_handle, "nrn_property_array_get");
        function_map["nrn_property_array_get"] = nrn_property_array_get;
        function_map["create_FInitializeHandler"] = create_FInitializeHandler;
        nrn_property_set_ = (void (*)(Object*, const char*, double)) DLL_GET_PROC(neuron_handle, "nrn_property_set");
        function_map["nrn_property_set"] = nrn_property_set;
        nrn_property_array_set_ = (void (*)(Object*, const char*, int, double)) DLL_GET_PROC(neuron_handle, "nrn_property_array_set");
        function_map["nrn_property_array_set"] = nrn_property_array_set;
        // function_map["nrn_get_value_ref"] = nrn_get_value_ref;
        function_map["nrn_vector_data_ref"] = nrn_vector_data_ref;
        // function_map["nrnref_get_index"] = nrnref_get_index;
        // function_map["nrnref_get"] = nrnref_get;
        // function_map["nrnref_set_index"] = nrnref_set_index;
        function_map["nrnref_set"] = nrnref_set;
        function_map["nrnref_get_n_elements"] = nrnref_get_n_elements;
        function_map["nrnref_set_n_elements"] = nrnref_set_n_elements;
        nrn_section_is_active_ = (bool (*)(Section*)) DLL_GET_PROC(neuron_handle, "nrn_section_is_active");
        function_map["nrn_section_is_active"] = nrn_section_is_active;
        nrn_rangevar_set_ = (void (*)(Symbol*, Section*, double, double)) DLL_GET_PROC(neuron_handle, "nrn_rangevar_set");
        function_map["nrn_rangevar_set"] = nrn_rangevar_set;
        nrn_get_plotshape_interface_ = (ShapePlotInterface* (*)(Object*)) DLL_GET_PROC(neuron_handle, "nrn_get_plotshape_interface");
        function_map["nrn_get_plotshape_interface"] = nrn_get_plotshape_interface;
        nrn_symbol_is_array_ = (bool (*)(Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_is_array");
        function_map["nrn_symbol_is_array"] = nrn_symbol_is_array;
        function_map["get_plot_data"] = get_plot_data;
        nrn_get_plotshape_section_list_ = (Object* (*)(ShapePlotInterface*)) DLL_GET_PROC(neuron_handle, "nrn_get_plotshape_section_list");
        nrn_get_plotshape_varname_ = (const char* (*)(ShapePlotInterface*)) DLL_GET_PROC(neuron_handle, "nrn_get_plotshape_varname");
        nrn_get_plotshape_low_ = (float (*)(ShapePlotInterface*)) DLL_GET_PROC(neuron_handle, "nrn_get_plotshape_low");
        nrn_get_plotshape_high_ = (float (*)(ShapePlotInterface*)) DLL_GET_PROC(neuron_handle, "nrn_get_plotshape_high");
        nrn_get_plotshape_low_ = (float (*)(ShapePlotInterface*)) DLL_GET_PROC(neuron_handle, "nrn_get_plotshape_low");
        function_map["nrn_get_plotshape_low"] = nrn_get_plotshape_low;
        nrn_get_plotshape_high_ = (float (*)(ShapePlotInterface*)) DLL_GET_PROC(neuron_handle, "nrn_get_plotshape_high");
        function_map["nrn_get_plotshape_high"] = nrn_get_plotshape_high;
        function_map["nrn_symbol_type"] = nrn_symbol_type;
        function_map["nrn_symbol"] = nrn_symbol;
        function_map["nrn_get_plotshape_varname"] = nrn_get_plotshape_varname;
        nrn_symbol_array_length_ = (int (*)(Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_array_length");
        function_map["nrn_symbol_array_length"] = nrn_symbol_array_length;
        nrn_section_Ra_get_ = (double (*)(Section*)) DLL_GET_PROC(neuron_handle, "nrn_section_Ra_get");
        function_map["nrn_section_Ra_get"] = nrn_section_Ra_get;
        nrn_section_Ra_set_ = (void (*)(Section*, double)) DLL_GET_PROC(neuron_handle, "nrn_section_Ra_set");
        function_map["nrn_section_Ra_set"] = nrn_section_Ra_set;
        nrn_section_rallbranch_get_ = (double (*)(Section*)) DLL_GET_PROC(neuron_handle, "nrn_section_rallbranch_get");
        function_map["nrn_section_rallbranch_get"] = nrn_section_rallbranch_get;
        nrn_section_rallbranch_set_ = (void (*)(Section*, double)) DLL_GET_PROC(neuron_handle, "nrn_section_rallbranch_set");
        function_map["nrn_section_rallbranch_set"] = nrn_section_rallbranch_set;
        // function_map["nrn_get_ref"] = nrn_get_ref;
        nrn_rangevar_push_ = (void (*)(Symbol*, Section*, double)) DLL_GET_PROC(neuron_handle, "nrn_rangevar_push");
        function_map["nrn_rangevar_push"] = nrn_rangevar_push;
        nrn_property_push_ = (void (*)(Object*, const char*)) DLL_GET_PROC(neuron_handle, "nrn_property_push");
        function_map["nrnref_property_push"] = nrnref_property_push;
        nrn_property_array_push_ = (void (*)(Object*, const char*, int)) DLL_GET_PROC(neuron_handle, "nrn_property_array_push");
        nrn_double_ptr_pop_ = (double* (*)(void)) DLL_GET_PROC(neuron_handle, "nrn_double_ptr_pop");
        function_map["nrn_double_ptr_pop"] = nrn_double_ptr_pop;
        function_map["nrn_symbol_dataptr"] = nrn_symbol_dataptr;
        // function_map["nrn_get_ref_from_symbol"] = nrn_get_ref_from_symbol;
        nrn_symbol_push_ = (void (*)(Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_push");
        function_map["nrn_symbol_push"] = nrn_symbol_push;
        function_map["nrn_symbol_nrnref"] = nrn_symbol_nrnref;
        function_map["nrnref_get_name"] = nrnref_get_name;
        function_map["nrnref_get_class"] = nrnref_get_class;
        function_map["nrnref_symbol_get"] = nrnref_symbol_get;        
        function_map["nrnref_symbol_set"] = nrnref_symbol_set;
        function_map["nrn_vector_nrnref"] = nrn_vector_nrnref;
        function_map["nrnref_vector_get"] = nrnref_vector_get; 
        function_map["nrnref_vector_set"] = nrnref_vector_set; 
        function_map["nrn_rangevar_nrnref"] = nrn_rangevar_nrnref;   
        function_map["nrnref_symbol_push"] = nrnref_symbol_push;     
        function_map["nrnref_rangevar_get"] = nrnref_rangevar_get;
        function_map["nrnref_rangevar_set"] = nrnref_rangevar_set;
        function_map["nrnref_property_get"] = nrnref_property_get;
        function_map["nrnref_property_set"] = nrnref_property_set;
        function_map["nrn_pp_property_nrnref"] = nrn_pp_property_nrnref;
        function_map["nrn_pp_property_array_nrnref"] = nrn_pp_property_array_nrnref;
        function_map["nrnref_rangevar_push"] = nrnref_rangevar_push;
        nrn_section_ref_ = (void (*)(Section*)) DLL_GET_PROC(neuron_handle, "nrn_section_ref");
        nrn_section_unref_ = (void (*)(Section*)) DLL_GET_PROC(neuron_handle, "nrn_section_unref");
        function_map["nrn_section_ref"] = nrn_section_ref;
        function_map["nrn_section_unref"] = nrn_section_unref;
        function_map["nrnref_vector_push"] = nrnref_vector_push;
        nrn_cas_ = (Section* (*)(void)) DLL_GET_PROC(neuron_handle, "nrn_cas");
        function_map["nrn_cas"] = nrn_cas;
        function_map["nrn_sectionlist_iterator_free"] = nrn_sectionlist_iterator_free;
        function_map["nrn_sectionlist_iterator_new"] = nrn_sectionlist_iterator_new;
        function_map["nrn_sectionlist_iterator_next"] = nrn_sectionlist_iterator_next;
        function_map["nrn_sectionlist_iterator_done"] = nrn_sectionlist_iterator_done;
        nrn_prop_exists_ = (bool (*)(const Object*)) DLL_GET_PROC(neuron_handle, "nrn_prop_exists");
        function_map["nrn_prop_exists"] = nrn_prop_exists;
       

        // Clean up
        //DLL_FREE(wrapper_handle);
        //DLL_FREE(neuron_handle);
    }
    if (nrhs) {
        std::string name = getStringFromMxArray(prhs[0]);
        
        auto item = function_map.find(name);
        if (item != function_map.end()) {
            // call it
            item->second(prhs, plhs);
        } else {
            mexErrMsgIdAndTxt("MyModule:unknownFunction", "Function name not recognized.");
        }
    }
}