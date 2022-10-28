% Proof of concept for running NEURON in MATLAB:
% Cleaning up Section from memory; causes a crash upon deleting the last
% remaining Section.

% Initialization.
clear;
setup0_paths;
n = neuron.Neuron();
n.reset_sections();

% Make section.
main = neuron.Section("main");
branch1 = neuron.Section("branch1");
branch1.connect(0, main, 1);
branch2 = neuron.Section("branch2");
branch2.connect(0, main, 1);
n.topology();

% Delete sections.
delete(branch2);
n.topology();
delete(branch1);
n.topology();
delete(main);
n.topology();