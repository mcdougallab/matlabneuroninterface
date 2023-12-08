% Minimal Exp3Syn/CVode/n.celcius example.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.launch();
n.reset_sections();
n.load_file('stdrun.hoc');

% squid like it cold
n.celsius = 6.3;
soma = n.Section("soma");
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

l0 = length(t_spikes);
t0 = t_spikes(1);
disp(l0);  % 1
disp(t0);  % 6.1000

% now let's try changing to variable step
cv = n.CVode();
cv.active(1);

n.finitialize(-65);
n.continuerun(10);

l1 = length(t_spikes);
t1 = t_spikes(1);
disp(l1);  % 1
disp(t1);  % 6.0676

% mammals like it warmer
n.celsius = 37;
n.finitialize(-65);
n.continuerun(10);

% the cell should not spike for that input when it's this warm
l2 = length(t_spikes);
disp(l2);  % 0


% Revert back to non-variable step for next run.
cv.active(0);
n.dt = 0.025;
n.celsius = 6.3;
