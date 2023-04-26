% Setup Neuron paths.
% Run this function once to set up your Matlab session for Neuron interaction.
function setup()

    % User setting:
    NeuronInstallationDirectory  = 'C:\nrn';

    % Check if NEURON directory is correct.
    filename = fullfile(NeuronInstallationDirectory , 'bin', 'libnrniv.dll');
    assert(exist(filename, 'file') == 2, 'NEURON directory not found.');
    
    % All dependencies of the generated interface library must be findable.
    % WINDOWS: Put them on the PATH
    dllpath = fullfile(NeuronInstallationDirectory , 'bin');
    syspath = getenv('PATH'); 
    if ~contains(string(syspath), string(dllpath)+pathsep)
        setenv('PATH', [dllpath pathsep syspath]);
    end
    
    % Path to the current directory.
    mlnrnpath = fileparts(mfilename('fullpath'));
    addpath(mlnrnpath);
    
    % Path to the generated interface library.
    addpath(fullfile(mlnrnpath, 'neuron'));
    
    % Path to example scripts and tests.
    addpath(fullfile(mlnrnpath, 'examples'));
    addpath(fullfile(mlnrnpath, 'examples', 'basic_functionality'));
    addpath(fullfile(mlnrnpath, 'examples', 'input'));
    addpath(fullfile(mlnrnpath, 'examples', 'morphology'));
    addpath(fullfile(mlnrnpath, 'examples', 'plotting'));
    addpath(fullfile(mlnrnpath, 'examples', 'simulation'));
    addpath(fullfile(mlnrnpath, 'tests'));

end
