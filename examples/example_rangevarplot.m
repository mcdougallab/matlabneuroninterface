% Init neuron.
clear;
setup;
n = neuron.Neuron();
n.reset_sections();

% Make section.
dend = n.Section("dend");
dend.nseg = 100;
dend.length = 6.28;

% Set voltage; also set explicitly at start and end points.
v_ref = dend.ref("v", 0);
v_ref.set(sin(0 * dend.length))
for i=0:dend.nseg-1
    segment = (double(i) + 0.5) / double(dend.nseg);
    v_ref = dend.ref("v", segment);
    disp(segment * dend.length);
    v_ref.set(sin(segment * dend.length));
end
v_ref = dend.ref("v", 1);
v_ref.set(sin(1 * dend.length))

% Plot result with RangeVarPlot.
rvp = n.RangeVarPlot(dend, "v", 0, 1);
x = n.Vector();
y = n.Vector();
rvp.to_vector(y, x);
plot(x, y);