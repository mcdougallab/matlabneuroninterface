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
n.print_t_v();

% Advance the simulation by one time step.
n.fadvance();

% Print V, t
n.print_t_v();