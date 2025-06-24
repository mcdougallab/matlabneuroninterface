% Proof of concept for running NEURON in MATLAB:
% Generates a plot of an action potential.

% Initialization.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.launch();
n.reset_sections();

% Make axon.
axon = n.Section('axon');
axon.nseg = 3;
axon.diam = 50;
axon.insert_mechanism("hh");

% Connect branch.
branch = n.Section('branch1');
branch.diam = 10;
branch.L = 1000;
branch.connect(0, axon, 1);
n.topology();

% Track time with Vector t_vec.
t_vec = n.Vector();
t = n.ref('t');
t_vec.record(t);

% Track voltage at two points.
v1_vec = n.Vector();
v1 = axon.ref('v', 0.5);
branch.nseg = 7;

v1_vec.record(v1);
v2_vec = n.Vector();
v2 = branch.ref('v', 1);
v2_vec.record(v2);

% Insert current at start of axon.
iclamp = n.IClamp(axon, 0);
iclamp.del = 1;
iclamp.dur = 1;
iclamp.amp = 50;

% Run simulation.
n.finitialize(-65);
while n.t < 10
    n.fadvance();
end

% Display the number of active Vectors and IClamps.
veclist = n.List('Vector');
icllist = n.List('IClamp');
disp("Number of Vectors: " + veclist.count());
disp("Number of IClamps: " + icllist.count());

% Plot results.
fig = figure;
ax = axes(fig);
hold on;
% Providing a Vector as an input to plot() calls Vector.double()
% in the background.
plot(ax, t_vec, v1_vec, "DisplayName", "Center of axon");
plot(ax, t_vec, v2_vec, "DisplayName", "End of branch");
hold off;
legend(ax);
title(ax, "Action potential");
xlabel(ax, "t (ms)");
ylabel(ax, "voltage (mV)");