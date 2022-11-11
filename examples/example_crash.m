% Try to cause a crash while running NEURON in MATLAB:
clear;
setup;
n = neuron.Neuron();
n.reset_sections();
v = n.Vector(10);

disp(v.contains());  
% With NEURON 9, the first time we run this example, it prints an error to 
% the console and does not crash! However, the second time we run it, it 
% still crashes...