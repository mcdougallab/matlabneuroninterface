%% Test vector example output.
example_vector;

% Asserts for first vector.
assert(isa(v, "neuron.Vector"));
assert(length(v) == 11);
assert(v(2) == 0.025);
assert(v(3) == 42);
assert(v(11) == 5);

% Asserts for second vector.
assert(isa(v, "neuron.Vector"));
assert(length(v2) == 6);
assert(v2(2) == 1);
assert(v2(6) == 5.3);

disp('Test passed.');
