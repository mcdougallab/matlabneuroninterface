% Proof of concept for running NEURON in MATLAB:
% Initialize a neuron session and call some functions.

% Initialization.
clear all;
setup0_paths;
n = neuron.Neuron();

% Run HOC code.
n.create_soma();
n.topology();
n.finitialize(3.14);

% Advance the simulation by one time step.
n.fadvance();

% Done.
n.close();

% Show results.
fprintf(1, '%s\n', fileread('stdout.txt'));
fprintf(2, '%s\n', fileread('stderr.txt'));