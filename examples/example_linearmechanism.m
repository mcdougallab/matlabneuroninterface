% Initialization.
clear;
setup;
n = neuron.Neuron();
n.reset_sections();

% Create section.
soma = n.Section("soma");

% Test LinearMechanism
c = n.Matrix(2, 2, 2);
g = n.Matrix(2, 2);
y = n.Vector(2);
b = n.Vector(2);
g.setval(0, 1, -1);
g.setval(1, 0, 1);
b.set(1, 10);
linmech = n.LinearMechanism(c, g, y, b, 0.5);
n.t = 0;
disp(n.t + " " + y.double(1) + " " + y.double(2));
for i=1:3
    n.fadvance();
    disp(n.t + " " + y.double(1) + " " + y.double(2));
end
