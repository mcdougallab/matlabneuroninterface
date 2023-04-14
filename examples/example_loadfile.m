% Initialization.
clear;
setup;
n = neuron.Neuron();

% Load stdrun.hoc; run n.continuerun
n.t = 0;
n.load_file('stdrun.hoc');
n.continuerun(5);
disp(n.t);