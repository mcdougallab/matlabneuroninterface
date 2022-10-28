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
branch = neuron.Section("branch");
branch.connect(0, main, 1);
n.topology();

% Delete sections.
delete(branch);
n.topology();
delete(main);
n.topology();