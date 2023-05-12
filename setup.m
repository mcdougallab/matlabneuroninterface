% Setup Neuron paths.
% Run this function once to set up your Matlab session for Neuron interaction.
function setup()

    % Path to the current directory.
    mlnrnpath = fileparts(mfilename('fullpath'));
    addpath(mlnrnpath);

    % Path to the generated interface library.
    addpath(utils.Paths.toolbox_lib_directory());

    % Path to example scripts.
    addpath(utils.Paths.examples_directory());
    addpath(fullfile(utils.Paths.examples_directory(), 'basic_functionality'));
    addpath(fullfile(utils.Paths.examples_directory(), 'input'));
    addpath(fullfile(utils.Paths.examples_directory(), 'morphology'));
    addpath(fullfile(utils.Paths.examples_directory(), 'plotting'));
    addpath(fullfile(utils.Paths.examples_directory(), 'simulation'));

    % Path to example scripts.
    addpath(utils.Paths.examples_directory());

    %  Check / set user-specific paths:
    % Has neuron_lib_directory been set correctly in utils.Paths?
    assert(exist(utils.Paths.libnrniv_file(), 'file') == 2, ...
        'The shared library file libnrniv is not found at the expected location. Update neuron_lib_directory in +utils/Paths.m. Expected location based on neuron_lib_directory: %s', utils.Paths.libnrniv_file());

    if ismac || isunix
        if ismac
            env_var = 'DYLD_LIBRARY_PATH';
            mex_dir = fullfile(matlabroot, "bin", "maci64");
        else
            env_var = 'LD_LIBRARY_PATH';
            mex_dir = fullfile(matlabroot, "bin", "glnxa64");
        end

        % All dependencies of the generated interface library must be
        % findable. Check if the (DY)LD_LIBRARY_PATH is set correctly. It
        % can't be set on runtime in matlab on unix and mac.
        hasMex = contains(getenv(env_var), mex_dir);
        hasNrn = contains(getenv(env_var), utils.Paths.neuron_lib_directory());
        assert(hasMex && hasNrn, "The mex library directory and neuron installation library directory are not on the %s. Mex library directory: %s Neuron installation library directory: %s", env_var, mex_dir, utils.Paths.neuron_lib_directory())

        % Use outofprocess execution, to avoid segmentation faults due to
        % conflicts between the neuron shared libraries and matlabs shared
        % libraries (mainly the libjvm that comes with matlab)
        % Note: when Matlab's new javascript based desktop becomes the
        % default, might be able to do inprocess also for Linux and Mac
        try
            % Do set outofprocess each time, because inprocess is the
            % default, and outofprocess might not persist across Matlab
            % versions.
            clibConfiguration("neuron", ExecutionMode="outofprocess");
        catch ME
            if "MATLAB:CPP:InterfaceLibraryNotFound" == ME.identifier
                % First time run, the neuron interface library has not been
                % generated yet.
            else
                % An unexpected error
                rethrow(ME)
            end
        end
    elseif ispc
        % All dependencies of the generated interface library must be
        % findable. Add the directory with the NEURON libraries to the
        % environments PATH 
        env_var = 'PATH';

        dllpath = utils.Paths.neuron_lib_directory();
        syspath = getenv(env_var);
        if ~contains(string(syspath), dllpath)
            setenv(env_var, [dllpath pathsep syspath]);
        end
    else
        disp('This platform not supported ... yet');
    end

end
