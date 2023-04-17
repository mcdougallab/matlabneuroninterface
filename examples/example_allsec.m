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
all_sections = neuron.allsec();
for i=1:numel(all_sections)
    disp(i + " " + all_sections{i}.name);
end

% Get all Sections back in the MATLAB workspace.
soma = all_sections{1};
dend1 = all_sections{2};
axon1 = all_sections{3};
axon2 = all_sections{4};
disp("dend1 length: " + dend1.length);
disp("axon2 length: " + axon2.length);

% Put the sections in a section_list.
sl = n.SectionList();
sl.append(soma);
sl.append(dend1);
sl.append(axon1);

% Remove a section; check that it does not show up in allsec(sl).
delete(dend1);
clear dend1;
all_sections = neuron.allsec(sl);
for i=1:width(all_sections)
    disp(i + " " + all_sections{i}.name);
end
