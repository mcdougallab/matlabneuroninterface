% Initialize a neuron session and call some hoc functions.

% Initialization.
clib.nrnmatlab.initialize();

% Run HOC code.
clib.nrnmatlab.hoc_run(3.14);

% Run HOC code.
% clib.nrnmatlab.fadvance(); % Crashes.

% Done.
clib.nrnmatlab.close();

% Show results.
disp(fileread('stdout.txt'));