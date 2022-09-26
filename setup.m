% Run this file once to set up your Matlab session for Neuron interaction.

% User setting:
if ispc
    NeuronInstallationDirectory = 'C:\nrn';
else
    % Assume neuron installed through conda, and this matlab session started
    % from within the activated conda environment
    % Note that within the conda env, the ncurses package needs to come from conda-forge
    [a, b] = system('which nrniv');
    b = strtrim(b);
    NeuronInstallationDirectory = fileparts(fileparts(b));
end

% Path to the generated interface library.
addpath nrnmatlab;

% All dependencies of the generated interface library must be findable.
if ispc
    % WINDOWS: Put them on the PATH
    dllpath = fullfile(NeuronInstallationDirectory, 'bin');
    syspath = getenv('PATH');
    setenv('PATH', [dllpath pathsep syspath]);
else
    dllpath = fullfile(NeuronInstallationDirectory, 'lib');
    syspath = getenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH', [dllpath pathsep syspath]);
end

% Create definition file for NEURON library.
HeaderFilePath = "bin/nrnmatlab.h";
if ispc
    LibPath = "bin/libnrniv.a";
else
    LibPath = fullfile(NeuronInstallationDirectory, 'lib', 'libnrniv.so');
end
clibgen.generateLibraryDefinition(HeaderFilePath, ...
    Libraries=LibPath, ...
    OverwriteExistingDefinitionFiles=true);

% Build the library interface.
build(definenrnmatlab);