#include <iostream>
#include <cstdlib>

#ifdef _WIN32
// Import C++ name mangled functions.
__declspec(dllimport) void ivocmain_session(int, const char**, 
                                            const char**, int);
// Import non-name mangled functions.
extern "C" __declspec(dllimport) int hoc_oc(const char*);
extern "C" __declspec(dllimport) void* hoc_lookup(const char*);
extern "C" __declspec(dllimport) double hoc_call_func(void*, int);
extern "C" __declspec(dllimport) void hoc_pushx(double);
#else 
// Import non-name mangled functions.
extern "C" void ivocmain_session(int, const char**, const char**, int);
extern "C" int hoc_oc(const char*);
extern "C" void* hoc_lookup(const char*);
extern "C" double hoc_call_func(void*, int);
extern "C" void hoc_pushx(double);
#endif

// Define invocmain_session input.
static const char* argv[] = {"nrn_test", "-nogui", NULL};

// Initialize.
void initialize(){
    // Initialize NEURON session.
    ivocmain_session(2, argv, NULL, 0);

    // Redirect stdout output to file, because MATLAB cannot handle it 
    // directly.
    freopen ("stdout.txt", "w", stdout);
}

// Call a few hoc functions.
void hoc_run(double finitialize_val){
    // Run HOC code.
    hoc_oc("create soma\n");
    hoc_call_func(hoc_lookup("topology"), 0);
    hoc_pushx(finitialize_val);
    hoc_call_func(hoc_lookup("finitialize"), 1);
    hoc_oc("print t, v\n");
}

// Finish up
void close(){
    // Close stdout output file.
    fclose(stdout);
}