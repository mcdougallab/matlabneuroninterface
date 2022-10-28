% Proof of concept for running NEURON in MATLAB:
% Generate activation function.

% Initialization.
clear;
setup0_paths;
n = neuron.Neuron();
n.reset_sections();

% Make axon.
axon = neuron.Section("axon");
axon.insert_mechanism("hh");
n.topology();

% Track time with Vector t_vec.
t_vec = neuron.Vector();
t = n.ref("t");
t_vec.record(t);

% Track voltage with Vector v_vec.
v_vec = neuron.Vector();
v = axon.ref("v", 0.5);
v_vec.record(v);

% Insert current.
iclamp = neuron.IClamp(axon, 0.5);
iclamp.del = 1;
iclamp.dur = 1;
iclamp.amp = 100;

% Run simulation.
n.finitialize(-65);
while n.t < 10
    n.fadvance();
end

% Plot results.
plot(t_vec, v_vec);
title("Action potential");
xlabel("t (ms)");
ylabel("voltage (mV)");