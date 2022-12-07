% Define and build Neuron interface.
% Run this function to generate the MATLAB-NEURON interface DLL.
function build_interface()

    % Set paths.
    setup;

    % Create definition file for NEURON library.
    HeaderFilePath = "bin/nrnmatlab.h";
    SourceFilePath = "bin/nrnmatlab.cpp";
    StaticLibPath = "bin/libnrniv.a";
    LibMexPath = fullfile(matlabroot, "extern", "lib", "win64", "mingw64", "libmex.lib"); % For mexPrintf
    HeadersIncludePath = "bin";
    clibgen.generateLibraryDefinition(HeaderFilePath, ...
        SupportingSourceFiles=SourceFilePath, ...
        Libraries=[StaticLibPath, LibMexPath], ...
        OverwriteExistingDefinitionFiles=true, ...
        IncludePath=HeadersIncludePath, ...
        PackageName="neuron", ...
        TreatObjectPointerAsScalar=true, ...
        TreatConstCharPointerAsCString=true);
    
    % We want to use the generated .m file, not the .mlx file.
    delete defineneuron.mlx
    
    % Automatically change lines:
    % - the Section attribute pt3d: `<MLTYPE>` is "clib.array.neuron.Pt3d", `<SHAPE>` is "npt3d"
    % - the function get_vector_vec: `<SHAPE>` is "len"
    change_from = {};
    change_from{1} = 'addProperty(SectionDefinition, "pt3d", "clib.neuron.Pt3d", 1, ... % <MLTYPE> can be "clib.neuron.Pt3d", or "clib.array.neuron.Pt3d"';
    change_from{2} = '%get_vector_vecDefinition = addFunction(libDef, ...';
    change_from{3} = '%    "double const * get_vector_vec(Object * vec,int len)", ...';
    change_from{4} = '%    "MATLABName", "clib.neuron.get_vector_vec", ...';
    change_from{5} = '%    "Description", "clib.neuron.get_vector_vec Representation of C++ function get_vector_vec."); % Modify help description values as needed.';
    change_from{6} = '%defineArgument(get_vector_vecDefinition, "vec", "clib.neuron.Object", "input", 1); % <MLTYPE> can be "clib.neuron.Object", or "clib.array.neuron.Object"';
    change_from{7} = '%defineArgument(get_vector_vecDefinition, "len", "int32");';
    change_from{8} = '%defineOutput(get_vector_vecDefinition, "RetVal", "clib.array.neuron.Double", <SHAPE>); % <MLTYPE> can be "clib.array.neuron.Double", or "double"';
    change_from{9} = '%validate(get_vector_vecDefinition);';
    change_to = {};
    change_to{1} = 'addProperty(SectionDefinition, "pt3d", "clib.array.neuron.Pt3d", "npt3d", ...';
    change_to{2} = 'get_vector_vecDefinition = addFunction(libDef, ...';
    change_to{3} = '    "double const * get_vector_vec(Object * vec,int len)", ...';
    change_to{4} = '    "MATLABName", "clib.neuron.get_vector_vec", ...';
    change_to{5} = '    "Description", "clib.neuron.get_vector_vec Representation of C++ function get_vector_vec.");';
    change_to{6} = 'defineArgument(get_vector_vecDefinition, "vec", "clib.neuron.Object", "input", 1);';
    change_to{7} = 'defineArgument(get_vector_vecDefinition, "len", "int32");';
    change_to{8} = 'defineOutput(get_vector_vecDefinition, "RetVal", "clib.array.neuron.Double", "len");';
    change_to{9} = 'validate(get_vector_vecDefinition);';
    func_replace_strings("defineneuron.m", "defineneuron.m", change_from, change_to)
    
    % Build the library interface.
    build(defineneuron);
end

function [] = func_replace_strings(InputFile, OutputFile, SearchStrings, ReplaceStrings)
    % read whole model file data into cell array
    fid = fopen(InputFile);
    data = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
    fclose(fid);
    % modify the cell array
    % find the position where changes need to be applied and insert new data
    for i = 1:length(data{1})
        for j = 1:length(SearchStrings)
            SearchString = SearchStrings{j};
            tf = strcmp(data{1}{i}, SearchString); % search for this string in the array
            if tf == 1
                data{1}{i} = ReplaceStrings{j}; % replace with this string
            end
        end
    end
    % write the modified cell array into the text file
    fid = fopen(OutputFile, 'w');
    for i = 1:length(data{1})
        fprintf(fid, '%s\n', char(data{1}{i}));
    end
    fclose(fid);
end
