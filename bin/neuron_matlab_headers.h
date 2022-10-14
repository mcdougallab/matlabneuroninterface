#ifndef NRNML_H
#define NRNML_H

// Helper struct for MATLAB interface.
struct NrnRef { /* Holds a pointer to a double. */
    double* ref;
    NrnRef(double* x) : ref(x) {}
};

#endif