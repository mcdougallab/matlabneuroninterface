% Init neuron.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.launch();
n.reset_sections();

% Make section.
dend = n.Section('dend');
dend.nseg = 100;
dend.length = 6.28;

% Set voltage; also set explicitly at start and end points.
segments = dend.allseg();  % allseg gives segments with endpoints included.
for i=1:numel(segments)
    segments{i}.v = sin(segments{i}.x * dend.length);
end

% Plot result with RangeVarPlot.
rvp = n.RangeVarPlot(dend, 'v', 0, 1);
rvp.plot();
xlabel('x');
ylabel('v');
