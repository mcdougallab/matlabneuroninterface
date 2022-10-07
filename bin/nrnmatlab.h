#include <iostream>
#include <cstdlib>

// Import C++ name mangled functions.
__declspec(dllimport) void ivocmain_session(int, const char**, 
                                            const char**, int);
__declspec(dllimport) void nrnmpi_stubs();  // We need to check if this exists in case the user compiled their own code...

// Import non-name mangled functions and parameters.
extern "C" __declspec(dllimport) int hoc_oc(const char*);
extern "C" __declspec(dllimport) void* hoc_lookup(const char*);
extern "C" __declspec(dllimport) double hoc_call_func(void*, int);
extern "C" __declspec(dllimport) void hoc_pushx(double);
extern "C" __declspec(dllimport) int nrn_main_launch;
extern "C" __declspec(dllimport) int nrn_nobanner_;

// Define invocmain_session input.
static const char* argv[] = {"nrn_test", "-nogui", NULL};

// Initialize NEURON session.
void initialize(){
    // Redirect stdout/sterr output to file, because MATLAB cannot handle 
    // it directly. Maybe we can use GetStdHandle instead?
    freopen("stdout.txt", "w", stdout);
    freopen("stderr.txt", "w", stderr);

    // Initialize NEURON session.
    nrn_main_launch = 0;
    nrn_nobanner_ = 0; // 0 to write banner (to stderr), 1 to hide banner.
    ivocmain_session(2, argv, NULL, 0);
}

// Call a few hoc functions.
void hoc_run(double finitialize_val){
    // Run HOC code.
    hoc_oc("create soma\n");
    hoc_call_func(hoc_lookup("topology"), 0);
    hoc_pushx(finitialize_val);
    hoc_call_func(hoc_lookup("finitialize"), 1);
    std::cout << "time and voltage:" << std::endl;
    hoc_oc("print t, v\n");
}

// Run simulation.
void fadvance(){
    nrnmpi_stubs();
    hoc_call_func(hoc_lookup("fadvance"), 0);
    std::cout << "time and voltage:" << std::endl;
    hoc_oc("print t, v\n");
}

// Finish up: close stdout and stderr output files.
void close(){
    fclose(stdout);
    fclose(stderr);
}
