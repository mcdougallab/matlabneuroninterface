% Initialization.
n = neuron.Neuron();

% Save initial state.
state = n.SaveState();
disp("t = " + n.t);
state.save();

% Advance a few times.
n.fadvance();
n.fadvance();
disp("t = " + n.t);

% Restore state.
state.restore();
disp("t = " + n.t);
