% Initialization.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.launch();
n.reset_sections();

% Create section.
soma = n.Section('soma');
soma.insert_mechanism('hh');

% Test LinearMechanism
c = n.Matrix(2, 2, 2);
g = n.Matrix(2, 2);
y = n.Vector(2);
b = n.Vector(2);
g.setval(1, 2, -1);
g.setval(2, 1, 1);
b.set(2, 10);
linmech = n.LinearMechanism(soma, c, g, y, b, 0.5);

% Run simulation.
% Results can be compared to n.load_file('test_lm.hoc').
n.finitialize(-65);
v_ref = soma.ref('v', 0.5);
disp(n.t + " " + y.double(1) + " " + y.double(2));
for i=1:19
    n.fadvance();
    disp(n.t + " " + v_ref.get() + " " + y.double(2));
end

