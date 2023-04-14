clear;
setup;
n = neuron.Neuron();
axon = n.Section("axon");
v = axon.ref("v", 0.5);
es = n.ExpSyn(axon, 0.5);
nc = n.NetCon(v, es)
