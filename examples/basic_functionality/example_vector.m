% Proof of concept for running NEURON in MATLAB:
% Initialize a neuron session, record time and call some vector methods.

% Initialization.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.launch();
n.reset_sections();
n('create soma');
n.topology();

% Try vector.
v = n.Vector();
disp("Before recording:");
disp(v.get_vec());
disp("Size: " + length(v));
disp(v.double());
disp("----------");

% Track time in vector.

% neuron_api('nrn_symbol_push', 't') % pushes a double star
% sym = neuron_api('nrn_method_symbol', self.obj, 'record');
% neuron_api('nrn_method_call', self.obj, sym, 1);

% nrnref = neuron_api('nrn_get_ref', neuron_api('nrn_symbol_dataptr', 't'), 1) % sym is t (get a ref to t)
% neuron_api('nrn_double_ptr_push', nrnref.obj); % nrnref.obj is the double*
% sym = neuron_api('nrn_method_symbol', self.obj, 'record'); % sym is record
% neuron_api('nrn_method_call', self.obj, sym, 1);


v.record(n.ref('t'));
n.finitialize(-65);
disp("Tracking 10 time steps with Vector.record()...");
for i = 1:4
    disp("t: "+n.t);
    n.fadvance();
end
n.t = 3.14;
for i = 5:9
    disp("t: "+n.t);
    n.fadvance();
end
v.append(5.);
disp("After 9 x fadvance() and 1 x append():")
disp(v.get_vec());
disp("Size: " + length(v));
disp(v.double());
disp("----------");

% Set/get vector elements directly.
disp("Old value: " + v(3));
v(3) = 42;
disp("New value: " + v(3));

% Get some properties using dynamically generated methods.
% See also: v.list_methods();
disp("mean: " + v.mean());
disp("stdev: " + v.stdev());
disp("contains 0.0: " + v.contains(0.0));
disp("contains 1.0: " + v.contains(1.0));
disp("----------");

% Make vector from list.
v2 = n.Vector([0 1 2 3 4 5.3]);
disp("Vector from list:");
disp(v2.double());
disp(v2(end));
disp("----------");

% Chained method call.
v2_max = v2.append(10).append(11).append(12).max();
disp(v2_max);