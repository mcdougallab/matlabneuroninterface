clear;
setup;
n = neuron.Neuron();
n.load_file('stdrun.hoc');
n.reset_sections();

n.celsius = 6.3;
soma = n.Section(name="soma");
soma.insert("hh");
soma.nseg = 11;

syn1 = n.Exp2Syn(soma(0.25));
syn.tau1 = 0.1;
syn.tau2 = 4;

ns = n.NetStim();
ns.start = 5;
ns.number = 1;
ns.noise = 0;

nc = n.NetCon(ns, syn1);
nc.weight = 1;
nc.delay = 0;

t = n.Vector();
t.record(n.ref("t"));
v = n.Vector();
v.record(soma(0.5).ref("v"));

nc_recorder = n.NetCon(soma(0.5).ref("v"), n.null);
t_spikes = n.Vector();
nc_recorder.record(t_spikes);

n.finitialize(-65);
n.continuerun(10);

disp(length(t_spikes));  % 1
disp(t_spikes(1));  % 6.1000 (on first run only)

% Variable step.
cv = n.CVode();
cv.active(1);

n.finitialize(-65);
n.continuerun(10);

disp(length(t_spikes));  % 1
disp(t_spikes(1));  % 6.0676

n.celsius = 37;
n.finitialize(-65);
n.continuerun(10);

disp(length(t_spikes));  % 0


% Revert back to non-variable step for next run.
cv.active(0);
n.dt = 0.025;
