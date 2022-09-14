% Run this file once to set up your Matlab session for Neuron interaction

% User setting:
NeuronInstallationDirectory = 'D:\Neuron\NeuronInstallation\nrn';

% Path to the generated interface library
addpath nrnmatlab;

% All dependencies of the generated interface library must be findable
% WINDOWS: Put them on the PATH
dllPath = fullfile(NeuronInstallationDirectory, 'bin');
syspath = getenv('PATH'); 
setenv('PATH',[dllPath pathsep syspath]);