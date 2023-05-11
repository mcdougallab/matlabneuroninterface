#!/bin/bash

export DYLD_LIBRARY_PATH='/Applications/MATLAB_R2023a.app/bin/maci64: \
                        /Applications/MATLAB_R2023a.app/sys/os/maci64: \
                        <... matlabneuroninterface ...>/neuron/: \
                        <... neuron-directory ...>/lib/:'$DYLD_LIBRARY_PATH
echo $DYLD_LIBRARY_PATH

matlab