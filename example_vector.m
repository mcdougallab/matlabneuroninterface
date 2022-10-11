% Proof of concept for running NEURON in MATLAB:
% Initialize a neuron session and call some vector methods.

% Initialization.
clib.neuron.initialize();

% Try vector.
my_vec = Vector(7);
disp(my_vec.data());

% Get some properties.
disp("mean: " + my_vec.mean());
disp("stdev: " + my_vec.stdev());
disp("size: " + my_vec.size());
disp("sum: " + my_vec.sum());
disp("sumsq: " + my_vec.sumsq());

% Done.
clib.neuron.close();

% Show results.
% fprintf(1, '%s\n', fileread('stdout.txt'));
% fprintf(2, '%s\n', fileread('stderr.txt'));