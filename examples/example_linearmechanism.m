% Initialization.
clear;
setup;
n = neuron.Neuron();
n.reset_sections();

% Create section.
soma = n.Section("soma");

c = n.Matrix(2, 2, 2);
g = n.Matrix(2, 2);
y = n.Vector(2);
b = n.Vector(2);
g.setval(0, 1, -1);
g.setval(1, 0, 1);
b.set(1, 10);
linmech = n.LinearMechanism(c, g, y, b, 0.5);
