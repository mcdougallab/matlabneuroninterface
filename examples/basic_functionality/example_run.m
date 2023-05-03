% Proof of concept for running NEURON in MATLAB:
% Initialize a neuron session and call some functions.

% Initialization.
n = neuron.Neuron();
n.reset_sections();

% Run HOC code.
n.hoc_oc("create soma");
n.topology();
n.finitialize(3.14);
n.hoc_oc("print t, v");

% Advance the simulation by one time step.
n.fadvance();

% Print time, voltage.
n.hoc_oc("print t, v");