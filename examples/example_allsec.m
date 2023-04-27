% Initialization.
clear;
setup;
n = neuron.Neuron();
n.reset_sections();

% Make sections.
n.hoc_oc("create soma");
dend1 = n.Section("dend1");
dend1.length = 37;
clear dend1;  % Remove MATLAB object from workspace; still exists in NEURON.
n.hoc_oc("create axon1");
dend2 = n.Section("dend2");
delete(dend2);  % Remove NEURON C++ object.
clear dend2;  % Remove MATLAB object from workspace.
axon2 = n.Section("axon2");
axon2.length = 42;
n.topology();

% Iterate over sections.
all_sections = n.allsec();
for i=1:numel(all_sections)
    disp(i + " " + all_sections{i}.name);
end

% Get all Sections back in the MATLAB workspace.
soma_new = all_sections{1};
dend1_new = all_sections{2};
axon1_new = all_sections{3};
axon2_new = all_sections{4};
disp("dend1_new length: " + dend1_new.length);
disp("axon2_new length: " + axon2_new.length);

% Iterate over all segments of a section
soma_new.nseg = 5;
soma_segs = soma_new.segments();
for i=1:numel(soma_segs)
    disp("Segment location: " + soma_segs{i}.x);
end

% Put the sections in a section_list.
sl = n.SectionList();
sl.append(soma_new);
sl.append(dend1_new);
sl.append(axon1_new);

% Remove a section; check that it does not show up in allsec(sl).
delete(dend1_new);
clear dend1_new;
all_sections = n.allsec(sl);
for i=1:width(all_sections)
    disp(i + " " + all_sections{i}.name);
end
