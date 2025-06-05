% Minimal AlphaSynapse example.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.launch();
n.reset_sections();

n.load_file('stdrun.hoc');

soma = n.Section('soma');
soma.insert_mechanism('hh');
soma.nseg = 11;
soma.diam = 11;
soma.L = 11;

% Note: AlphaSynapse defines an alpha function conductance
% at a pre-chosen time; it does not work with NetCon objects.
syn = n.AlphaSynapse(soma(0.25));
syn.tau = 1;
syn.gmax = 1;
syn.onset = 0.2;
syn.e = 42;

ivec = n.Vector();
ivec.record(syn.ref('i'));
t = n.Vector();
t.record(n.ref('t'));
v = n.Vector();
v.record(soma(0.5).ref('v'));

n.finitialize(-65);
n.continuerun(10);

disp(ivec(43));  % -1.9125
disp(v(101));  % 28.7358
