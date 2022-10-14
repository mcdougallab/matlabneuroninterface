#ifndef NRNML_H
#define NRNML_H

// Helper class for MATLAB interface.
class NrnRef { /* Holds a pointer to a double. */
    public:
        double* ref;
        NrnRef(double* x) {
            ref = x;
        }
        void set(double x) {
            *ref = x;
        }
        double get() {
            return *ref;
        }
};

#endif