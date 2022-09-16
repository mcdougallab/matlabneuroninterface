% Initialization.
clib.nrnmatlab.initialize();

% Run HOC code.
clib.nrnmatlab.hoc_run(42.1337);

% Done.
clib.nrnmatlab.close();

% Show results.
disp(fileread('stdout.txt'));