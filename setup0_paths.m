% Run this file once to set up your Matlab session for Neuron interaction.

% User setting:
NeuronInstallationDirectory = 'C:\nrn';

% Check if NEURON directory is correct.
filename = fullfile(NeuronInstallationDirectory, 'bin', 'libnrniv.dll');
assert(exist(filename, 'file') == 2, 'NEURON directory not found.');

% All dependencies of the generated interface library must be findable.
% WINDOWS: Put them on the PATH
dllpath = fullfile(NeuronInstallationDirectory, 'bin');
syspath = getenv('PATH'); 
setenv('PATH', [dllpath pathsep syspath]);

% Path to the generated interface library.
addpath neuron;
