#!/bin/bash

# ONLY the first three variables should need to be set. However, depending on
# how NEURON was installed, also the relative parts of the second set of three variables
# might need to be adapted.
# Do include the final slash as part of these paths

# The directory where libmex is installed
NRNML_LIBMEXPATH="<..matlabroot..>/bin/glnxa64/"
# The 'neuron' directory within the directory where this toolbox is installed
NRNML_INTERFACEPATH="<..matlabneuroninterface..>/neuron/"
# The directory where NEURON is installed, see also the next three variables
NRNML_NRNPATH="<..neuron-directory..>/"

# Exact location of the following subdirectories might depend on how NEURON was installed, do check!
# Directory containing libnrniv, libnrnpython3, libcorenrnmech_internal shared libraries
NRNML_LIBNRNPATH="${NRNML_NRNPATH}lib/"
# Directory containing stdlib.hoc, stdrun.hoc and many more .hoc files
NRNML_HOCNRNPATH="${NRNML_NRNPATH}share/nrn/lib/hoc/"

# Update to LD_LIBRARY_PATH needed, to find dependencies of the interface library
export LD_LIBRARY_PATH="${NRNML_LIBMEXPATH}:${NRNML_LIBNRNPATH}:${NRNML_INTERFACEPATH}:${LD_LIBRARY_PATH}"
echo ${LD_LIBRARY_PATH}
# Update to HOC_LIBRARY_PATH needed, to be able to find the .hoc files distributed with NEURON
export HOC_LIBRARY_PATH="${NRNML_HOCNRNPATH}:${HOC_LIBRARY_PATH}"
echo ${HOC_LIBRARY_PATH}

# Update to PATH needed, to be able to find nrnivmodl for compiling mod files?
# It should usually NOT be needed to update the PATH variable, but it does depend on how NEURON is installed.
# If it is needed to update the path, it would be to be able to find the correct nrnivmodl.
# An example for a conda environment named neuron9:
# - The correct nrnivmodl will be in envs/neuron9/bin
# - The underlying nrnivmodl, that should NOT be put on the path, is in envs/neuron9/lib/python3.11/site-packages/neuron/.data/bin
# Thus, a correct path could be
#NRNML_BINNRNPATH="${HOME}/.conda/envs/neuron9/bin/"
#export PATH="${PATH}:${NRNML_BINNRNPATH}:"
echo ${PATH}

matlab