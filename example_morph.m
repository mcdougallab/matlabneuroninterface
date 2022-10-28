% Proof of concept for running NEURON in MATLAB:
% Morphology.

% Initialization.
clear;
setup0_paths;
n = neuron.Neuron();

% Make sections.
main = neuron.Section("main");
branch1 = neuron.Section("branch1");
branch2 = neuron.Section("branch2");

% Change number of segments.
main.change_nseg(3);

% Connect beginning of branches to end of main.
branch1.connect(0, main, 1);
branch2.connect(0, main, 1);

% Show topology.
n.topology();

% Add 3D points to main.
main.addpoint(1, 2, 3, 4);
main.addpoint(201, 2, 3, 1);

% Set abstract morphology info for branches.
branch1.length = 100;
disp(branch1.length);
branch1.set_diameter(1);
branch2.length = 150;
branch2.set_diameter(0.9);

% Construct 3D points for branches.
n.define_shape();

% Set up simple simulation.
main.insert_mechanism("pas");
iclamp = neuron.IClamp(main, 0);
iclamp.del = 0;
iclamp.dur = 10000;
iclamp.amp = 1;

% Run for 10 steps.
n.finitialize(-65);
for i=1:10
    n.fadvance();
end

% Print info.
branch1.info();
