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
void (*nrn_function_call_)(char const* name, int narg) = nullptr;

Symlist* (*nrn_global_symbol_table_)(void) = nullptr;
Symlist* (*nrn_top_level_symbol_table_)(void) = nullptr;
SymbolTableIterator* (*nrn_symbol_table_iterator_new_)(Symlist* my_symbol_table) = nullptr;
void (*nrn_symbol_table_iterator_free_)(SymbolTableIterator* st) = nullptr;
char const* (*nrn_symbol_table_iterator_next_)(SymbolTableIterator* st) = nullptr;
int (*nrn_symbol_table_iterator_done_)(SymbolTableIterator* st) = nullptr;

Symbol* (*nrn_symbol_)(char const* const name) = nullptr;
int (*nrn_symbol_type_)(const Symbol* sym) = nullptr;
int (*nrn_symbol_subtype_)(const Symbol* sym) = nullptr;

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
            // Get the name of the current symbol
            const char* name = nrn_symbol_table_iterator_next_(iter);

            // Retrieve the symbol object and its type/subtype
            Symbol* sym = nrn_symbol_(name);
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
/*
commented out because this is wrong: it takes a symbol* and narg
void nrn_function_call(const mxArray* prhs[], mxArray* plhs[]) {
    auto [name, narg] = extractParams<std::string, int>(prhs, 1);
    nrn_function_call_(name.c_str(), narg);
}
*/

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
        nrn_global_symbol_table_ = (Symlist*(*)(void)) DLL_GET_PROC(neuron_handle, "nrn_global_symbol_table");
        nrn_top_level_symbol_table_ = (Symlist*(*)(void)) DLL_GET_PROC(neuron_handle, "nrn_top_level_symbol_table");
        nrn_symbol_table_iterator_new_ = (SymbolTableIterator* (*)(Symlist*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_table_iterator_new");
        nrn_symbol_table_iterator_free_ = (void (*)(SymbolTableIterator*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_table_iterator_free");
        nrn_symbol_table_iterator_next_ = (char const* (*)(SymbolTableIterator*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_table_iterator_next");
        nrn_symbol_table_iterator_done_ = (int (*)(SymbolTableIterator*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_table_iterator_done");
        nrn_symbol_ = (Symbol* (*)(char const* const)) DLL_GET_PROC(neuron_handle, "nrn_symbol");
        nrn_symbol_type_ = (int (*)(const Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_type");
        nrn_symbol_subtype_ = (int (*)(const Symbol*)) DLL_GET_PROC(neuron_handle, "nrn_symbol_subtype");
        //nrn_function_call_ = (void(*)(const char*,int)) DLL_GET_PROC(neuron_handle, "nrn_function_call");
        //function_map["nrn_function_call"] = nrn_function_call;


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