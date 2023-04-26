% Test outputs of example_vector example script.
example_vector;

% Asserts for first vector.
assert(length(v) == 11)
assert(v(2) == 0.025);
assert(v(3) == 42);
assert(v(11) == 5);

% Asserts for second vector.
assert(length(v2) == 6)
assert(v2(2) == 1);
assert(v2(6) == 5.3);

disp('Test passed.');
