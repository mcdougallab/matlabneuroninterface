% Setup Neuron paths.
% Run this function once to set up your Matlab session for Neuron interaction.
function setup()

    % User setting:
    if ismac
        % Here just check if it is in DYLD_LIBRARY_PATH, you can't set it on
        % runtime in matlab.
        NeuronInstallationDirectory = getenv('CONDA_PREFIX'); % equivalent to '/home/kian.ohara/.conda/envs/neuron9/';
        % Check if NEURON directory is correct.
        filename = fullfile(NeuronInstallationDirectory, 'bin', 'nrniv');

        assert(exist(filename, 'file') == 2, 'macOS needs to be started from a shell where the neuron binary (nrniv) declared in the DYLD_LIBRARY_PATH');
        % All dependencies of the generated interface library must be findable.
        % LINUX: Put them on the DYLD_LIBRARY_PATH
        OSsyspathenv = 'DYLD_LIBRARY_PATH';

    elseif isunix
        % Here just check if it is in LD_LIBRARY_PATH, you can't set it on
        % runtime in matlab.
        NeuronInstallationDirectory = getenv('CONDA_PREFIX'); % equivalent to '/home/kian.ohara/.conda/envs/neuron9/';
        % Check if NEURON directory is correct.
        filename = fullfile(NeuronInstallationDirectory, 'bin', 'nrniv');

        assert(exist(filename, 'file') == 2, 'Linux needs to be started from a shell where the neuron binary (nrniv) declared in the LD_LIBRARY_PATH');
        % All dependencies of the generated interface library must be findable.
        % LINUX: Put them on the LD_LIBRARY_PATH
        OSsyspathenv = 'LD_LIBRARY_PATH';
    elseif ispc
        % Here just check if it is in LD_LIBRARY_PATH, you can't set it on
        % runtime in matlab.
        NeuronInstallationDirectory = 'C:\nrn';

        % Check if NEURON directory is correct.
        filename = fullfile(NeuronInstallationDirectory, 'bin', 'libnrniv.dll');

        assert(exist(filename, 'file') == 2, 'NEURON directory not found.');
        % All dependencies of the generated interface library must be findable.
        % WINDOWS: Put them on the PATH
        OSsyspathenv='PATH';

        dllpath = fullfile(NeuronInstallationDirectory, 'bin');
        syspath = getenv(OSsyspathenv);
        if ~contains(string(syspath), string(dllpath)+pathsep)
            setenv(OSsyspathenv, [dllpath pathsep syspath]);
        end

    else
        disp('This platform not supported ... yet');
    end

    % Path to the current directory.
    mlnrnpath = fileparts(mfilename('fullpath'));
    addpath(mlnrnpath);

    % Path to the generated interface library.
    addpath(fullfile(mlnrnpath, 'neuron'));

    % Path to example scripts.
    addpath(fullfile(mlnrnpath, 'examples'));
    addpath(fullfile(mlnrnpath, 'examples', 'basic_functionality'));
    addpath(fullfile(mlnrnpath, 'examples', 'input'));
    addpath(fullfile(mlnrnpath, 'examples', 'morphology'));
    addpath(fullfile(mlnrnpath, 'examples', 'plotting'));
    addpath(fullfile(mlnrnpath, 'examples', 'simulation'));

end
