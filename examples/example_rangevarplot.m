% Init neuron.
clear;
setup;
n = neuron.Neuron();
n.reset_sections();

% Make section with varying voltage.
dend = n.Section("dend");
dend.nseg = 55;
dend.length = 6.28;
for i=0:dend.nseg+1
    segment = double(i) / double(dend.nseg+1);
    v_ref = dend.ref("v", segment);
    disp(segment * dend.length);
    v_ref.set(sin(segment * dend.length));
end

% Plot result with RangeVarPlot.
rvp = n.RangeVarPlot(dend, "v", 0, 1);
v = n.Vector();
rvp.to_vector(v);
plot(v);