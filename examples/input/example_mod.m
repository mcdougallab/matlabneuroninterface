% Initialization.
clear;
setup;
n = neuron.Neuron();

% If we try to find 'hd' mechanism here, we get:
% Error: Insertable mechanism 'hd' not found. 
% axon = n.Section("axon");
% axon.insert_mechanism("hd");  % Error!

% Compile mod file.
examples_path = fileparts(mfilename('fullpath'));
mod_path = fullfile(examples_path, 'mod');
system("nrnivmodl " + mod_path);
output_path = fullfile(pwd, 'nrnmech.dll');
dll_path = fullfile(mod_path, 'nrnmech.dll');
movefile(output_path, dll_path);

% Import dll into neuron.
n.nrn_load_dll(strrep(dll_path, "\", "/"));

% Try to find 'hd' mechanism; now it should exist.
axon = n.Section("axon");
axon.insert_mechanism("hd");  % No error!

% Try to find NMDA object.
syn = n.NMDA(axon(0.5));
disp(syn);  % Displays: "Beta: 0.0066, e: 45, Alpha: 0.0720"
syn.e = 42;
disp(syn.e);  % Displays: 42
