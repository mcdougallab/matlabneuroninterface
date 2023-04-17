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
segments = dend.segment_locations(true);
for i=1:numel(segments)
    v_ref = dend.ref("v", segments(i));
    v_ref.set(sin(segments(i) * dend.length));
end

% Plot result with RangeVarPlot.
rvp = n.RangeVarPlot(dend, "v", 0, 1);
x = n.Vector();
y = n.Vector();
rvp.to_vector(y, x);
plot(x, y);