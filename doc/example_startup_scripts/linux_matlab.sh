#!/bin/bash

export LD_LIBRARY_PATH='matlabneuroninterface/neuron/:<neuron-directory>/lib/':$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH

matlab