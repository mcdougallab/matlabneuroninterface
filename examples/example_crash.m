% Try to cause a crash while running NEURON in MATLAB
% Fixed for nrn9!
clear;
setup;
n = neuron.Neuron();
n.reset_sections();
v = n.Vector(10);

disp(v.contains());  
disp(n.L);
