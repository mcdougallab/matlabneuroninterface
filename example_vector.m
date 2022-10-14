% Proof of concept for running NEURON in MATLAB:
% Initialize a neuron session, record time and call some vector methods.

% Initialization.
clib.neuron.initialize();
clib.neuron.create_soma();
clib.neuron.topology();

% Try vector.
t_vec = Vector();
disp("Before recording:");
disp(t_vec.vec);
disp(t_vec.size());
disp(t_vec.data());
disp("----------");

% Track time in vector.
t_vec.record(clib.neuron.ref("t"));
clib.neuron.finitialize(-65);
disp("Tracking 10 time steps with Vector.record()...");
for i = 1:10
    clib.neuron.fadvance();
end
disp("After 10 x fadvance():")
disp(t_vec.vec);
disp(t_vec.size());
disp(t_vec.data());
disp("----------");

% Get some properties.
disp("mean (using .hoc_get()): " + t_vec.hoc_get("mean"));
disp("sumsq (using .hoc_get()): " + t_vec.hoc_get("sumsq"));
disp("mean: " + t_vec.mean());
disp("stdev: " + t_vec.stdev());
disp("size: " + t_vec.size());
disp("sum: " + t_vec.sum());
disp("sumsq: " + t_vec.sumsq());

% Done.
clib.neuron.close();

% Show results.
% fprintf(1, '%s\n', fileread('stdout.txt'));
% fprintf(2, '%s\n', fileread('stderr.txt'));