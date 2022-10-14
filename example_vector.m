% Proof of concept for running NEURON in MATLAB:
% Initialize a neuron session, record time and call some vector methods.

% Initialization.
n = Neuron();
n.create_soma();
n.topology();

% Try vector.
v = Vector();
disp("Before recording:");
disp(v.vec);
disp(v.size());
disp(v.data());
disp("----------");

% Track time in vector.
v.record(n.ref("t"));
n.finitialize(-65);
disp("Tracking 10 time steps with Vector.record()...");
for i = 1:10
    n.fadvance();
end
disp("After 10 x fadvance():")
disp(v.vec);
disp(v.size());
disp(v.data());
disp("----------");

% Get some properties.
disp("mean (using .hoc_get()): " + v.hoc_get("mean"));
disp("sumsq (using .hoc_get()): " + v.hoc_get("sumsq"));
disp("mean: " + v.mean());
disp("stdev: " + v.stdev());
disp("size: " + v.size());
disp("sum: " + v.sum());
disp("sumsq: " + v.sumsq());

% Done.
n.close();

% Show results.
% fprintf(1, '%s\n', fileread('stdout.txt'));
% fprintf(2, '%s\n', fileread('stderr.txt'));