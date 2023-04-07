clear;
setup;
n = neuron.Neuron();
n.reset_sections();

axon = n.Section("axon");
rvp = n.RangeVarPlot(axon, "v");
