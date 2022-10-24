% Proof of concept for running NEURON in MATLAB:
% Initialize a neuron session, record time and call some vector methods.

% Initialization.
clear;
setup0_paths;
n = neuron.Neuron();
n.hoc_oc("create soma");
n.topology();

% Try vector.
v = neuron.Vector();
disp("Before recording:");
disp(v.get_vec());
disp("Size: " + length(v));
disp(v.double());
disp("----------");

% Track time in vector.
t = n.ref("t");
v.record(t);
n.finitialize(-65);
disp("Tracking 10 time steps with Vector.record()...");
for i = 1:4
    disp("t: "+n.t);
    n.fadvance();
end
t.set(3.14);
for i = 5:9
    disp("t: "+n.t);
    n.fadvance();
end
disp("After 9 x fadvance():")
disp(v.get_vec());
disp("Size: " + length(v));
disp(v.double());
disp("----------");

% Get some properties using dynamically generated methods.
% See also: v.list_methods();
disp("mean: " + v.mean());
disp("stdev: " + v.stdev());
disp("contains 0.0: " + v.contains(0.0));
disp("contains 1.0: " + v.contains(1.0));