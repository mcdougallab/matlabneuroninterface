% Proof of concept for running NEURON in MATLAB:
% Creating and editing a morphology.

% Initialization.
clear;
setup;
n = neuron.Neuron();
n.reset_sections();

% Make sections.
main = n.Section("main");
branch1 = n.Section("branch1");
branch2 = n.Section("branch2");

% Change number of segments.
main.nseg = 3;

% Connect beginning of branches to end of main.
branch1.connect(0, main, 1);
branch2.connect(0, main, 1);

% Show topology.
n.topology();

% Add 3D point to main.
main.addpoint(1, 2, 3, 4);

% Alternative way to add 3D point to main using dynamic top-level function.
main.push();
n.pt3dadd(201, 2, 3, 1);
n.pop_section();

% Set abstract morphology info for branches.
branch1.length = 100;
branch1.set_diameter(1);
branch2.length = 150;
branch2.set_diameter(0.9);

% Construct 3D points for branches.
n.define_shape();

% Set up simple simulation.
main.insert_mechanism("pas");
iclamp = n.IClamp(main, 0);
iclamp.del = 0;
iclamp.dur = 10000;
iclamp.amp = 1;

% Run for 10 steps.
n.finitialize(-65);
for i=1:10
    n.fadvance();
end

% Print info, 2 ways.
branch1.psection();
branch1.info();

% We are unhappy with branch2, so let's remove it.
n.topology();
delete(branch2);  % Remove from neuron.
clear branch2;  % Remove from matlab.
n.topology();
