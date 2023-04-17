% Proof of concept for running NEURON in MATLAB:
% Generates a plot of an action potential.

% Initialization.
clear;
setup;
n = neuron.Neuron();
n.reset_sections();

% Make sections.
n.hoc_oc("create soma");
dend1 = n.Section("dend1");
n.hoc_oc("create axon");
n.topology();

% Iterate over sections.
all_sections = neuron.allsec();
for i=1:width(all_sections)
    disp(i + " " + clib.neuron.secname(all_sections{i}));
end
