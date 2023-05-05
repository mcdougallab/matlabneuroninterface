% Initialization.
clearvars -except test;  % Make sure testing params are not cleared.
n = neuron.Neuron();
n.reset_sections();
soma = n.Section("soma");
n.finitialize(-65);

% Save initial state.
state = n.SaveState();
t0 = n.t;
disp("t = " + t0);
state.save();

% Advance a few times.
n.fadvance();
n.fadvance();
t1 = n.t;
disp("t = " + t1);

% Restore state.
state.restore();
t2 = n.t;
disp("t = " + t2);
