% Cause a crash while running NEURON in MATLAB:
clear;
setup0_paths;
n = neuron.Neuron();
v = neuron.Vector(10);

disp(v.contains());  
% Prints stderr to screen before crashing:
%
% nrn_test: contains not enough arguments
%  near line 0
%  objref hoc_obj_[2]
%                    ^
%         Vector[0].contains()