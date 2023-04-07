clear;
setup;
n = neuron.Neuron();
n.reset_sections();

axon = n.Section("axon");
vref = axon.ref("v", 0.5);

ps = n.PlotShape();
