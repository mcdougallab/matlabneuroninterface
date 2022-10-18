% Proof of concept for running NEURON in MATLAB:
% Generate activation function.

% Initialization.
setup0_paths;
n = Neuron();
axon = Section("axon");
axon.insert_mechanism("hh");

% Track time with Vector t_vec.
t_vec = Vector();
t = n.ref("t");
t_vec.record(t);

% Track voltage with Vector v_vec.
v_vec = Vector();
v = axon.ref("v", 0.5);
v_vec.record(v);

% Insert current.
iclamp = IClamp(0.5);
iclamp.del = 1;
iclamp.dur = 1;
iclamp.amp = 100;

% Run simulation.
n.finitialize(-65);
while t.get() < 10
    n.fadvance();
end

% Plot results.
plot(t_vec.data(), v_vec.data());
title("Action potential");
xlabel("t (ms)");
ylabel("voltage (mV)")

% Done.
n.close();

% Show results.
% fprintf(1, '%s\n', fileread('stdout.txt'));
% fprintf(2, '%s\n', fileread('stderr.txt'));