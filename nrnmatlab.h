#include <iostream>
#include <cstdlib>

// Import C++ name mangled functions.
__declspec(dllimport) void ivocmain_session(int, const char**, const char**, int);

// Import non-name mangled functions.
extern "C" __declspec(dllimport) int hoc_oc(const char*);
extern "C" __declspec(dllimport) void* hoc_lookup(const char*);
extern "C" __declspec(dllimport) double hoc_call_func(void*, int);
extern "C" __declspec(dllimport) void hoc_pushx(double);

// Define invocmain_session input.
static const char* argv[] = {"nrn_test", "-nogui", NULL};

int run(double finitialize_val){

    // Redirect stdout output to file, because MATLAB cannot handle it.
    freopen ("stdout.txt", "w", stdout);

    // Initialize.
    ivocmain_session(2, argv, NULL, 0);

    // Run HOC code.
    hoc_oc("create soma\n");
    hoc_call_func(hoc_lookup("topology"), 0);
    hoc_pushx(finitialize_val);
    hoc_call_func(hoc_lookup("finitialize"), 1);
    hoc_oc("print t, v\n");

    // Finish up.
    fclose (stdout);
    return 1;
}