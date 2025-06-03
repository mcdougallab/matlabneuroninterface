% Initialization.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.launch();
n.reset_sections();

% Define topology.
main = n.Section('main');
branch1 = n.Section('branch1');
branch2 = n.Section('branch2');
branch3 = n.Section('branch3');
main.diam = 4;
branch1.diam = 3;
branch2.diam = 2;
branch3.diam = 1;
main.L = 30;
branch1.L = 10;
branch2.L = 20;
branch3.L = 5;
branch1.connect(0, main, 1);
branch2.connect(0, main, 1);
branch3.connect(0, main, 0.5);
main.nseg = 5;
main(0.5).diam = 8;
branch3.nseg = 2;
branch3(1).diam = 3;
n.topology();

% Make PlotShape of all Sections.
ps_all = n.PlotShape(false);
ps_all.scale(0, 8);
ps_all.plot();

% Make PlotShape of some Sections.
sl_some = n.SectionList();
sl_some.append(main);
sl_some.append(branch2);
ps_some = n.PlotShape(sl_some);
ps_some.variable('v');
ps_some.scale(-1, 6);
ps_some.plot();
