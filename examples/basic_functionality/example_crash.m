% Try to cause a crash while running NEURON in MATLAB
n = neuron.Neuron();
n.reset_sections();
as = n.allsec();
disp(as{1});
