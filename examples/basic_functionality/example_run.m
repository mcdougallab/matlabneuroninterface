% Proof of concept for running NEURON in MATLAB:
% Initialize a neuron session and call some functions.

% Initialization.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.launch();
n.reset_sections();

% Run HOC code.
n('create soma');
n.topology();
n.finitialize(3.14);
n('print t, v');

% Advance the simulation by one time step.
n.fadvance();

% Print time, voltage.
n('print t, v');