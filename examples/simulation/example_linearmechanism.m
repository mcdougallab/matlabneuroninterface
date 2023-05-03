% Initialization.
clear;
setup;
n = neuron.Neuron();
n.reset_sections();

% Create section.
soma = n.Section("soma");
soma.insert_mechanism("hh");

% Test LinearMechanism
c = n.Matrix(2, 2, 2);
g = n.Matrix(2, 2);
y = n.Vector(2);
b = n.Vector(2);
g.setval(0, 1, -1);
g.setval(1, 0, 1);
b.set(1, 10);
linmech = n.LinearMechanism(soma, c, g, y, b, 0.5);

% Run simulation.
n.finitialize(-65);
v_ref = soma.ref("v", 0.5);
n.t = 0;
disp(n.t + " " + y.double(1) + " " + y.double(2));
for i=1:20
    n.fadvance();
    disp(n.t + " " + v_ref.get() + " " + y.double(2));
end

% Compare.
n.load_file("examples/simulation/test_lm.hoc");