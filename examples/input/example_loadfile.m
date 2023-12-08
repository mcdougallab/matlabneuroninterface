% Initialization.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.launch();
n.reset_sections();
soma = n.Section("soma");

% Load stdrun.hoc; run n.continuerun
examples_path = fileparts(mfilename('fullpath'));
hoc_file_path = strrep(fullfile(examples_path, 'stdrun.hoc'), '\', '/');  % Path with backslashes does not work.
n.load_file(hoc_file_path);

n.finitialize(-65);
n.continuerun(5);  % Only available if file loaded successfuly.
disp(n.t);
