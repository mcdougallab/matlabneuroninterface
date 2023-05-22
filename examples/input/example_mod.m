% Initialization.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.Neuron();
n.reset_sections();

% If we try to find 'hd' mechanism here, we get:
% Error: Insertable mechanism 'hd' not found. 
% axon = n.Section("axon");
% axon.insert_mechanism("hd");  % Error!

% Compile mod file.
examples_path = fileparts(mfilename('fullpath'));
mod_path = fullfile(examples_path, 'mod');
system("nrnivmodl " + mod_path);

if ispc    
    libfile = 'nrnmech.dll';
    output_path = fullfile(pwd, libfile);
elseif ismac
    % What is the filename, and where is it created, on mac?
    libfile = 'libnrnmech.so';
    output_path = fullfile(pwd, 'x86_64', libfile);
    error('Not implemented yet, please update this file with correct file and directory name')
else
    libfile = 'libnrnmech.so';
    output_path = fullfile(pwd, 'x86_64', libfile);
end
dll_path = fullfile(mod_path, libfile);
try
    movefile(output_path, dll_path, 'f');
catch
    warning("Could not move shared library file; does the file already exist?");
    delete(output_path);
end

% Import dll into neuron.
try
    % Also for linux and mac use nrn_load_dll
    n.nrn_load_dll(strrep(dll_path, "\", "/"));
catch
    warning("Could not load shared library file; is it already loaded?");
end

% Try to find 'hd' mechanism; now it should exist.
axon = n.Section("axon");
axon.insert_mechanism("hd");  % No error!

% Try to find NMDA object.
syn = n.NMDA(axon(0.5));
disp(syn);  % Displays: "Beta: 0.0066, e: 45, Alpha: 0.0720"
syn.e = 42;
disp(syn.e);  % Displays: 42
