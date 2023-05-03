% Initialization.
n = neuron.Neuron();

% Load stdrun.hoc; run n.continuerun
n.t = 0;
examples_path = fileparts(mfilename('fullpath'));
hoc_file_path = strrep(fullfile(examples_path, 'stdrun.hoc'), '\', '/');  % Path with backslashes does not work.
n.load_file(hoc_file_path);
n.continuerun(5);  % Only available if file loaded successfuly.
disp(n.t);
