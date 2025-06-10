% Initialization.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.launch();
n.reset_sections();

% Make sections.
n.hoc('create soma');
dend1 = n.Section('dend1');
dend1.L = 37;
clear dend1;  % Remove section.
axon1 = n.Section('axon1');
axon2 = n.Section('axon2');
axon2 = n.Section('axon2');  % Overwrites previous section.
axon2.L = 42;
n.topology();

% Iterate over sections.
all_sections = n.allsec();
for i=1:numel(all_sections)
    disp(i + " " + all_sections{i}.name);
end

% Get all Sections back in the MATLAB workspace.
soma_new = all_sections{1};
axon1_new = all_sections{2};
axon2_new = all_sections{3};
disp("axon2_new length: " + axon2_new.L);

% Iterate over all segments of a section
soma_new.nseg = 5;
soma_segs = soma_new.segments();
for i=1:numel(soma_segs)
    disp("Segment location: " + soma_segs{i}.x);
end

% Put the sections in a section_list.
sl = n.SectionList();
sl.append(soma_new);
sl.append(axon1_new);
sl.append(axon2_new);

% Removing a non-owner section does nothing.
clear axon1_new;
penultimate_sections = n.allsec(sl);
for i=1:width(penultimate_sections)
    disp(i + " " + penultimate_sections{i}.name);
end

% Remove a section; check that it does not show up in allsec(sl).
clear axon1;
ultimate_sections = n.allsec(sl);
for i=1:width(ultimate_sections)
    disp(i + " " + ultimate_sections{i}.name);
end