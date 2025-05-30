% Initialization.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.launch();
n.reset_sections();

% Make sections.

axon1 = n.Section('axon1');

% Iterate over sections.
all_sections = n.allsec();
for i=1:numel(all_sections)
    disp(i + " " + all_sections{i}.name);
end

% Get all Sections back in the MATLAB workspace.
axon1_new = all_sections{1};

% Iterate over all segments of a section

% Put the sections in a section_list.
sl = n.SectionList();
sl.append(axon1_new);

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
