classdef Paths
    %PATHS Single class to hold all file and directory path definitions
    %   The same paths are needed in multiple locations in the code. Set
    %   them here once.
    %   The paths can be accessed through static methods, thus no instance
    %   of the class is needed.
    %   The returned values are character arrays.
    %
    %   Example:
    %     pathvalue = utils.Paths.NeuronLibDirectory;


    methods (Static)
        % The function neuron_lib_directory should be the first in this
        % list, since that is the only one where a user might need to
        % change the value being returned.
        
        function value = neuron_lib_directory()
            % The directory containing the libnrniv shared library file.
            if ismac
                value = '/Applications/nrn/lib';
            elseif isunix
                value = '/opt/nrn/lib';
            elseif ispc
                value = 'C:\nrn\bin';
            else
                error('Unknown operating system');
            end
            % Make sure only native filesep are used.
            value = fullfile(value);
        end

        function value = libnrniv_file()
            % Full path of the libnrniv shared library file.
            lib_dir = utils.Paths.neuron_lib_directory();
            if ismac
                value = fullfile(lib_dir, 'libnrniv.dylib');
            elseif isunix
                value = fullfile(lib_dir, 'libnrniv.so');
            elseif ispc
                value = fullfile(lib_dir, 'libnrniv.dll');
            else
                error('Unknown operating system');
            end
        end

        function value = toolbox_directory()
            % Full path of the top level directory of this toolbox
            value = fileparts(fileparts(mfilename("fullpath")));
        end

        function value = toolbox_lib_directory()
            value = fullfile(utils.Paths.toolbox_directory(), 'neuron');

        end

        function value = examples_directory()
            value = fullfile(utils.Paths.toolbox_directory(), 'examples');

        end

        function value = matlab_lib_directory()
            % The directory containing the matlab shared library files.
            if ismac
                value = fullfile(matlabroot, "bin", "maci64");
            elseif isunix
                value = fullfile(matlabroot, "bin", "glnxa64");
            elseif ispc
                value = fullfile(matlabroot, "extern", "lib", "win64", "mingw64");
            else
                error('Unknown operating system');
            end
            % Make sure only native filesep are used.
            value = fullfile(value);
        end

        function value = libmex_file()
            % Full path of the libmex shared library file.
            lib_dir = utils.Paths.matlab_lib_directory();
            if ismac
                value = fullfile(lib_dir, 'libmex.dylib');
            elseif isunix
                value = fullfile(lib_dir, 'libmex.so');
            elseif ispc
                value = fullfile(lib_dir, 'libmex.lib');
            else
                error('Unknown operating system');
            end
        end
    end
end

