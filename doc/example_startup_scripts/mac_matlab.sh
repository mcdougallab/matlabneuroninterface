#!/bin/bash

# ONLY the first three variables should need to be set. However, depending on
#   how NEURON or MATLAB was installed, also the relative parts of the second set of variables
#   might need to be adapted.
# DO include the final slash as part of these paths!
# 1. The main directory where MATLAB is installed, probably /Applications/MATLAB_R2023a.app/
NRNML_MLROOT = "<..matlabroot..>/"
# 2. The 'neuron' directory within the directory where this toolbox is installed
NRNML_INTERFACEPATH="<..matlabneuroninterface..>/neuron/"
# 3. The directory where NEURON is installed, see also the next three variables
NRNML_NRNPATH="<..neuron-directory..>/"

# Exact location of the following subdirectories might depend on how MATLAB was installed
# The directory within the MATLAB installation where libmex is installed
NRNML_MLLIBMEXPATH="${NRNML_MLROOT}bin/maci64/"
# The directory within the MATLAB installation where other dylibs are installed
NRNML_MLLIBSPATH="${NRNML_MLROOT}sys/os/maci64/"
# The directory within the MATLAB installation where the MATLAB executable is installed
NRNML_MLEXEPATH="${NRNML_MLROOT}Contents/MacOS/"
# Exact location of the following subdirectories might depend on how NEURON was installed, do check!
# Directory containing nrnivmodl executable
NRNML_BINNRNPATH="${NRNML_NRNPATH}bin/"
# Directory containing libnrniv, libnrnpython3, libcorenrnmech_internal shared libraries
NRNML_LIBNRNPATH="${NRNML_NRNPATH}lib/"
# Directory containing stdlib.hoc, stdrun.hoc and many more .hoc files
NRNML_HOCNRNPATH="${NRNML_NRNPATH}share/nrn/lib/hoc/"

# Update to PATH needed, to be able to find nrnivmodl executable for compiling mod files
export PATH="${PATH}:${NRNML_BINNRNPATH}:"
echo ${PATH}
# Update to DYLD_LIBRARY_PATH needed, to find dependencies of the interface library
export DYLD_LIBRARY_PATH="${NRNML_MLLIBMEXPATH}:${NRNML_MLLIBSPATH}:${NRNML_LIBNRNPATH}:${NRNML_INTERFACEPATH}:${DYLD_LIBRARY_PATH}"
echo ${DYLD_LIBRARY_PATH}
# Update to HOC_LIBRARY_PATH needed, to be able to find the .hoc files distributed with NEURON
export HOC_LIBRARY_PATH="${NRNML_HOCNRNPATH}:${HOC_LIBRARY_PATH}"
echo ${HOC_LIBRARY_PATH}

# Start matlab AND also set DYLD_LIBRARY_PATH on the same line!
#   Because as of MacOS 10.11, the "DYLD_LIBRARY_PATH" environment variable is stripped from the
#   environment when launching protected executables. To work around this, prepend the setting of
#   the variable right at the beginning of the command you run.
DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}" ${NRNML_MLEXEPATH}MATLAB
