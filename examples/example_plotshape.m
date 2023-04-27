% Initialization.
clear;
setup;
n = neuron.Neuron();
n.reset_sections();

% Define topology.
main = n.Section("main");
branch1 = n.Section("branch1");
branch2 = n.Section("branch2");
branch3 = n.Section("branch3");
main.set_diameter(4);
branch1.set_diameter(3);
branch2.set_diameter(2);
branch3.set_diameter(1);
main.length = 30;
branch1.length = 10;
branch2.length = 20;
branch3.length = 5;
branch1.connect(0, main, 1);
branch2.connect(0, main, 1);
branch3.connect(0, main, 0.5);
main.nseg = 5;
main(0.5).diam = 8;
branch3.nseg = 2;
branch3(1).diam = 3;
n.topology();
n.define_shape();

% Make PlotShape of all Sections.
ps_all = n.PlotShape(false);
ps_all.variable("diam");
ps_all.scale(0, 8);
ps_all.plot();

% Make PlotShape of some Sections.
sl_some = n.SectionList();
sl_some.append(main);
sl_some.append(branch2);
ps_some = n.PlotShape(sl_some);
ps_some.variable("v");
ps_some.scale(-1, 6);
ps_some.plot();
