% Proof of concept for running NEURON in MATLAB:
% Initialize a neuron session and call some functions.

% Initialization.
clib.neuron.initialize();

% Run HOC code.
clib.neuron.hoc_run(3.14);

% Run HOC code.
clib.neuron.fadvance();

% Done.
clib.neuron.close();

% Show results.
fprintf(1, '%s\n', fileread('stdout.txt'));
fprintf(2, '%s\n', fileread('stderr.txt'));