#!/bin/bash

export DYLD_LIBRARY_PATH='/Applications/MATLAB_R2022b.app/bin/maci64:/Applications/MATLAB_R2022b.app/sys/os/maci64:/Volumes/nobackup/kian.ohara/matlabneuroninterface/neuron/:/Users/kian.ohara/miniconda3/envs/neuron9/lib/python3.11/site-packages/neuron/.data/lib/:'$DYLD_LIBRARY_PATH
echo $DYLD_LIBRARY_PATH

matlab