% Run this file once to set up your Matlab session for Neuron interaction

% User setting:
NeuronInstallationDirectory = 'C:\nrn';

% Path to the generated interface library
addpath nrnmatlab;

% All dependencies of the generated interface library must be findable
% WINDOWS: Put them on the PATH
dllPath = fullfile(NeuronInstallationDirectory, 'bin');
syspath = getenv('PATH'); 
setenv('PATH',[dllPath pathsep syspath]);

% Create definition file for NEURON library.
path_h = "bin/nrnmatlab.h";
path_a = "bin/libnrniv.a";

clibgen.generateLibraryDefinition(path_h, Libraries=path_a, ...
    OverwriteExistingDefinitionFiles=true);

% Build.
build(definenrnmatlab);