% Initialization.
clear;
setup;
n = neuron.Neuron();
n.reset_sections();

axon = n.Section("axon");
sl = n.SectionList();
sl.append(axon);
sl.printnames(); % outputs "axon"
ps = n.PlotShape(sl);