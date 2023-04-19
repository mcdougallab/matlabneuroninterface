% Initialization
clear;
setup;
n = neuron.Neuron();
n.reset_sections();

% Make section and vectors
soma = n.Section("soma ");
soma.insert_mechanism("hh");
seg = soma(0.5);
v = seg.ref("v");  % Equivalent to: v = soma.ref("v", 0.5);
% TODO: we cannot do soma(0.5).ref("v") directly, because of the way
% Section.subsref works...
v_vec = n.Vector();
v_vec.record(v);
t_vec = n.Vector();
t = n.ref("t");
t_vec.record(t);

% NetStim object
ns = n.NetStim();
ns.start = 5;
ns.noise = 1;
ns.interval = 5;
ns.number = 10;
disp(ns);

% ExpSyn object
syn = n.ExpSyn(soma(0.5));
syn.tau = 3;
syn.e = 0;
disp(syn);

% NetCon object
nc = n.NetCon(ns, syn);
vec = n.Vector();
nc.record(vec);
nc.weight = 0.5;
nc.delay = 0;
disp(ns);

% Run simulation.
n.finitialize(-65);
while n.t < 100
    n.fadvance();
end

% Plot results.
fig = figure;
ax = axes(fig);
hold on;
plot(ax, t_vec, v_vec);
hold off;
legend(ax);
title(ax, "Action potential");
xlabel(ax, "t (ms)");
ylabel(ax, "voltage (mV)");
