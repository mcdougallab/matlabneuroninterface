% Run this file once to set up your Matlab session for Neuron interaction.

% User setting:
NeuronInstallationDirectory = 'C:\nrn';

% Path to the generated interface library.
addpath nrnmatlab;

% All dependencies of the generated interface library must be findable.
% WINDOWS: Put them on the PATH
dllpath = fullfile(NeuronInstallationDirectory, 'bin');
syspath = getenv('PATH'); 
setenv('PATH', [dllpath pathsep syspath]);

% Create definition file for NEURON library.
HeaderFilePath = "bin/nrnmatlab.h";
StaticLibPath = "bin/libnrniv.a";
clibgen.generateLibraryDefinition(HeaderFilePath, ...
    Libraries=StaticLibPath, ...
    OverwriteExistingDefinitionFiles=true);

% Build the library interface.
build(definenrnmatlab);