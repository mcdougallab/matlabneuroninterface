% Initialization.
clear;
setup;
n = neuron.Neuron();

% Try to find 'hd' mechanism.
axon1 = n.Section("axon1");
axon1.insert_mechanism("hd");  % Warning: Insertable mechanism 'hd' not found. 

% Compile mod file.
examples_path = fileparts(mfilename('fullpath'));
mod_path = fullfile(examples_path, 'mod');
system("nrnivmodl " + mod_path);
output_path = fullfile(pwd, 'nrnmech.dll');
dll_path = fullfile(mod_path, 'nrnmech.dll');
system("move " + output_path + " " + dll_path);

% Import dll into neuron.
n.nrn_load_dll(strrep(dll_path, "\", "/"));

% Try again to find 'hd' mechanism; now it should exist.
axon2 = n.Section("axon2");
axon2.insert_mechanism("hd");  % No warning.
