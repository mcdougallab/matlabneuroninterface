% Setup Neuron paths.
% Run this function once to set up your Matlab session for Neuron interaction.
function setup()

    % User setting:
    NeuronInstallationDirectory = 'C:\nrn-dev';

    % Check if NEURON directory is correct.
    filename = fullfile(nrnpath, 'bin', 'libnrniv.dll');
    assert(exist(filename, 'file') == 2, 'NEURON directory not found.');
    
    % All dependencies of the generated interface library must be findable.
    % WINDOWS: Put them on the PATH
    dllpath = fullfile(nrnpath, 'bin');
    syspath = getenv('PATH'); 
    if ~contains(string(syspath), string(dllpath)+pathsep)
        setenv('PATH', [dllpath pathsep syspath]);
    end
    
    % Path to the generated interface library.
    addpath neuron;
    
    % Path to example scripts.
    addpath examples;

end
