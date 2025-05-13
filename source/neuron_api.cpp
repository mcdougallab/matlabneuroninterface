// compile via: mex CXXFLAGS="-std=c++17" neuron_api.cpp
#include "mex.h"
#include "/usr/local/include/neuronapi.h"
#include <stdio.h>
#include <array>
#include <tuple>
#include <unordered_map>
#include <string>


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

Symbol* (*nrn_symbol_)(char const* const name) = nullptr;
int (*nrn_symbol_type_)(const Symbol* sym) = nullptr;
int (*nrn_symbol_subtype_)(const Symbol* sym) = nullptr;
char const* (*nrn_symbol_name_)(const Symbol* sym) = nullptr;
double* (*nrn_symbol_dataptr_)(Symbol* sym) = nullptr;

Symbol* (*hoc_install_)(const char*, int, double, Symlist**) = nullptr;
void (*nrn_register_function_)(void (*)(), const char*) = nullptr;
char* (*hoc_gargstr_)(int) = nullptr;
void (*hoc_ret_)(void) = nullptr;
void (*hoc_pushx_)(double) = nullptr;
double (*hoc_xpop_)(void) = nullptr;
void (*hoc_call_ob_proc_)(Object*, Symbol*, int) = nullptr;

Object* (*nrn_object_new_)(Symbol* sym, int narg) = nullptr;
void (*nrn_object_unref_)(Object*) = nullptr;
char const* (*nrn_class_name_)(const Object*) = nullptr;
Symbol* (*nrn_method_symbol_)(Object*, char const* const) = nullptr;
void (*nrn_method_call_)(Object*, Symbol*, int) = nullptr;

double* (*nrn_vector_data_)(Object*) = nullptr;

void (*nrn_section_pop_)(void) = nullptr;
char** (*nrn_pop_str_)(void) = nullptr;
Object* (*nrn_object_pop_)(void) = nullptr;

void (*nrn_str_push_)(char**) = nullptr;
void (*nrn_object_push_)(Object*) = nullptr;
void (*nrn_double_ptr_push_)(double*) = nullptr;
void (*nrn_section_push_)(Section*) = nullptr;

nrn_Item* (*nrn_allsec_)(void) = nullptr;
nrn_Item* (*nrn_sectionlist_data_)(Object*) = nullptr;
void (*nrn_mechanism_insert_)(Section*, const Symbol*) = nullptr;
double (*nrn_rangevar_get_)(Symbol*, Section*, double) = nullptr;
void (*nrn_section_connect_)(Section*, double, Section*, double) = nullptr;
void (*nrn_section_length_set_)(Section*, double) = nullptr;
double (*nrn_section_length_get_)(Section*) = nullptr;
const char* (*nrn_secname_)(Section*) = nullptr;
int (*nrn_nseg_get_)(Section const*) = nullptr;
void (*nrn_nseg_set_)(Section*, const int) = nullptr;
void (*nrn_segment_diam_set_)(Section*, const double, const double) = nullptr;

double (*nrn_property_get_)(Object const*, const char*) = nullptr;
double (*nrn_property_array_get_)(Object const*, const char*, int) = nullptr;
void (*nrn_property_set_)(Object*, const char*, double) = nullptr;
void (*nrn_property_array_set_)(Object*, const char*, int, double) = nullptr;

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
    if (mxGetClassID(mxStr) != mxCHAR_CLASS) {
        mexErrMsgIdAndTxt("MyModule:invalidInput", "Input must be a string.");
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
    double* ref;
    size_t n_elements;

    NrnRef(double* x) {
        this->ref = x;
        this->n_elements = 1;
    }

    NrnRef(double* x, size_t size) {
        this->ref = x;
        this->n_elements = size;
    }
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
    nrn_register_function_(nrnmatlab, "nrnmatlab");
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
    auto [type, func_name, instance_id] = extractParams<int, std::string, std::string>(prhs, 1);
    char* func_name_c = const_cast<char*>(func_name.c_str());
    char* instance_id_c = const_cast<char*>(instance_id.c_str());

    // Register the the callback in hoc
    nrn_register_function_(finitialize_callback, func_name_c);

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
    double* data = nrn_vector_data_(vec);
    plhs[0] = mxCreateDoubleScalar(*data);
}

void nrn_vector_data_ref(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* vec = reinterpret_cast<Object*>(obj_ptr);
    double* data = nrn_vector_data_(vec);
    int len = static_cast<int>(mxGetScalar(prhs[2]));
    NrnRef* ref = new NrnRef(data, len);
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);
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
    auto str = static_cast<char**>(mxCalloc(1, sizeof(char*)));
    *str = mxArrayToString(prhs[1]);
    nrn_str_push_(str);
    mxFree(*str);
    mxFree(str);
}

void nrn_object_push(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    nrn_object_push_(obj);
}

void nrn_double_ptr_push(const mxArray* prhs[], mxArray* plhs[]) {
    auto addr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    double* ptr = reinterpret_cast<double*>(addr);
    nrn_double_ptr_push_(ptr);
}

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
    auto sym_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Symbol* sym = reinterpret_cast<Symbol*>(sym_ptr);
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[2]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    auto [x] = extractParams<double>(prhs, 3);
    double result = nrn_rangevar_get_(sym, sec, x);
    plhs[0] = mxCreateDoubleScalar(result);
}

void nrn_rangevar_get_ref(const mxArray* prhs[], mxArray* plhs[]) {
    auto sec_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Section* sec = reinterpret_cast<Section*>(sec_ptr);
    auto sym_name = getStringFromMxArray(prhs[2]);
    Symbol* sym = nrn_symbol_(sym_name.c_str());
    auto [x] = extractParams<double>(prhs, 3);
    double result = nrn_rangevar_get_(sym, sec, x);
    double* result_ptr = &result;
    NrnRef* ref = new NrnRef(result_ptr);
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);
}

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

void nrn_property_get(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    auto [name] = extractParams<std::string>(prhs, 2);
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
    auto [name, value] = extractParams<std::string, double>(prhs, 2);
    nrn_property_set_(obj, name.c_str(), value);
}

void nrn_property_array_set(const mxArray* prhs[], mxArray* plhs[]) {
    auto obj_ptr = static_cast<uint64_t>(mxGetScalar(prhs[1]));
    Object* obj = reinterpret_cast<Object*>(obj_ptr);
    auto [name, index, value] = extractParams<std::string, int, double>(prhs, 2);
    nrn_property_array_set_(obj, name.c_str(), index, value);
}

void nrn_get_value_ref(const mxArray* prhs[], mxArray* plhs[]) {
    // Get string name
    std::string propname = getStringFromMxArray(prhs[1]);

    // Lookup symbol in top-level HOC context
    Symbol* sym = nrn_symbol_(propname.c_str());

    if (nrn_symbol_subtype_(sym) == 1) {
        // If subtype is 2, cast to int* and create NrnRef
        int* int_ptr = reinterpret_cast<int*>(nrn_symbol_dataptr_(sym));
        NrnRef* ref = new NrnRef(reinterpret_cast<double*>(int_ptr));
        plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
        *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);
    } else {
        // Otherwise, treat as double and create NrnRef
        double* value_ptr = nrn_symbol_dataptr_(sym);
        NrnRef* ref = new NrnRef(value_ptr);
        plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
        *(uint64_t*)mxGetData(plhs[0]) = reinterpret_cast<uint64_t>(ref);
    }
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
    
        static std::array<const char*, 4> argv = {"hh_sim", "-nogui", "-nopython", nullptr};
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
        nrn_symbol_ = (Symbol* (*)(char const* const)) DLL_GET_PROC(neuron_handle, "nrn_symbol");
        nrn_symbol_type_ = (int (*)(const Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_type");
        nrn_symbol_subtype_ = (int (*)(const Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_subtype");
        nrn_symbol_name_ = (char const* (*)(const Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_name");
        hoc_install_ = (Symbol* (*)(const char*, int, double, Symlist**)) DLL_GET_PROC(neuron_handle, "hoc_install");
        nrn_register_function_ = (void (*)(void (*)(), const char*)) DLL_GET_PROC(neuron_handle, "nrn_register_function");
        hoc_gargstr_ = (char* (*)(int)) DLL_GET_PROC(neuron_handle, "hoc_gargstr");
        hoc_ret_ = (void (*)(void)) DLL_GET_PROC(neuron_handle, "hoc_ret");
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
        function_map["nrn_double_ptr_push"] = nrn_double_ptr_push;
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
        nrn_property_get_ = (double (*)(Object const*, const char*)) DLL_GET_PROC(neuron_handle, "nrn_property_get");
        function_map["nrn_property_get"] = nrn_property_get;
        nrn_property_array_get_ = (double (*)(Object const*, const char*, int)) DLL_GET_PROC(neuron_handle, "nrn_property_array_get");
        function_map["nrn_property_array_get"] = nrn_property_array_get;
        function_map["create_FInitializeHandler"] = create_FInitializeHandler;
        nrn_property_set_ = (void (*)(Object*, const char*, double)) DLL_GET_PROC(neuron_handle, "nrn_property_set");
        function_map["nrn_property_set"] = nrn_property_set;
        nrn_property_array_set_ = (void (*)(Object*, const char*, int, double)) DLL_GET_PROC(neuron_handle, "nrn_property_array_set");
        function_map["nrn_property_array_set"] = nrn_property_array_set;
        function_map["nrn_get_value_ref"] = nrn_get_value_ref;
        function_map["nrn_vector_data_ref"] = nrn_vector_data_ref;
        function_map["nrn_rangevar_get_ref"] = nrn_rangevar_get_ref;
        
        
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