% Try to cause a crash while running NEURON in MATLAB:
clear;
setup;
n = neuron.Neuron();
n.reset_sections();
v = n.Vector(10);

disp(v.contains());  
% With NEURON 9, this prints error to screen and does not crash!