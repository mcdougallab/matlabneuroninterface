% Define and build Neuron interface.
% Run this function to generate the MATLAB-NEURON interface DLL.
% Before running it, make sure that:
% - The Neuron path is set (by running setup.m)
% - For Windows, your compiler is set to MinGW64 (using mex -setup)
% - For Windows+MingGW64, the static library file is present at
%   source/libnrniv.a (to generate it yourself, see doc/DEV_README.md)
function build_interface()

    % Check if there is a C++ compiler.
    if ~check_compiler('C++')
        error("No C++ compiler found.");
    elseif ispc && ~check_compiler('C++', 'mingw64-g++')
        error("On windows the C++ compiler must be mingw64")
    end

    % Create definition file for NEURON library.
    HeaderFilePath = "source/nrnmatlab.h";
    SourceFilePath = "source/nrnmatlab.cpp";
    StaticLibPath = "source/libnrniv.a";
    LibMexPath = fullfile(matlabroot, "extern", "lib", "win64", "mingw64", "libmex.lib"); % For mexPrintf
    HeadersIncludePath = "source";
    try
        clibgen.generateLibraryDefinition(HeaderFilePath, ...
            SupportingSourceFiles=SourceFilePath, ...
            Libraries=[StaticLibPath, LibMexPath], ...
            OverwriteExistingDefinitionFiles=true, ...
            IncludePath=HeadersIncludePath, ...
            PackageName="neuron", ...
            TreatObjectPointerAsScalar=true, ...
            TreatConstCharPointerAsCString=true);
    catch ME
        disp(ME);
        error("Error while running clibgen.generateLibraryDefinition(), please check if you have administrator rights.")
    end

    % We want to use the generated .m file, not the .mlx file, because we
    % will be making some automated changes to the contents of the file.
    if isfile('defineneuron.mlx')
        delete defineneuron.mlx
    end

    % Automatically change lines:
    % - the Section attribute pt3d: `<MLTYPE>` is "clib.array.neuron.Pt3d", `<SHAPE>` is "npt3d"
    change_lines = struct('from', {}, 'to', {});
    change_lines(end+1) = struct(...
        'from', 'addProperty(SectionDefinition, "pt3d", "clib.neuron.Pt3d", 1, ... % <MLTYPE> can be "clib.neuron.Pt3d", or "clib.array.neuron.Pt3d"', ...
        'to', 'addProperty(SectionDefinition, "pt3d", "clib.array.neuron.Pt3d", "npt3d", ...');
    % - the function get_vector_vec: `<SHAPE>` is "len"
    change_lines(end+1) = struct(...
        'from', '%get_vector_vecDefinition = addFunction(libDef, ...', ...
        'to', 'get_vector_vecDefinition = addFunction(libDef, ...');
    change_lines(end+1) = struct(...
        'from', '%    "double const * get_vector_vec(Object * vec,int len)", ...', ...
        'to', '    "double const * get_vector_vec(Object * vec,int len)", ...');
    change_lines(end+1) = struct(...
        'from', '%    "MATLABName", "clib.neuron.get_vector_vec", ...', ...
        'to', '    "MATLABName", "clib.neuron.get_vector_vec", ...');
    change_lines(end+1) = struct(...
        'from', '%    "Description", "clib.neuron.get_vector_vec Representation of C++ function get_vector_vec."); % Modify help description values as needed.', ...
        'to', '    "Description", "clib.neuron.get_vector_vec Representation of C++ function get_vector_vec.");');
    change_lines(end+1) = struct(...
        'from', '%defineArgument(get_vector_vecDefinition, "vec", "clib.neuron.Object", "input", 1); % <MLTYPE> can be "clib.neuron.Object", or "clib.array.neuron.Object"', ...
        'to', 'defineArgument(get_vector_vecDefinition, "vec", "clib.neuron.Object", "input", 1);');
    change_lines(end+1) = struct(...
        'from', '%defineArgument(get_vector_vecDefinition, "len", "int32");', ...
        'to', 'defineArgument(get_vector_vecDefinition, "len", "int32");');
    change_lines(end+1) = struct(...
        'from', '%defineOutput(get_vector_vecDefinition, "RetVal", "clib.array.neuron.Double", <SHAPE>); % <MLTYPE> can be "clib.array.neuron.Double", or "double"', ...
        'to', 'defineOutput(get_vector_vecDefinition, "RetVal", "clib.array.neuron.Double", "len");');
    change_lines(end+1) = struct(...
        'from', '%validate(get_vector_vecDefinition);', ...
        'to', 'validate(get_vector_vecDefinition);');
    % - the function secname needs to be uncommented
    change_lines(end+1) = struct(...
        'from', '%secnameDefinition = addFunction(libDef, ...', ...
        'to',  'secnameDefinition = addFunction(libDef, ...');
    change_lines(end+1) = struct(...
        'from', '%    "char * secname(Section * input1)", ...', ...
        'to', '    "char * secname(Section * input1)", ...');
    change_lines(end+1) = struct(...
        'from', '%    "MATLABName", "clib.neuron.secname", ...', ...
        'to', '    "MATLABName", "clib.neuron.secname", ...');
    change_lines(end+1) = struct(...
        'from', '%    "Description", "clib.neuron.secname Representation of C++ function secname."); % Modify help description values as needed.', ...
        'to', '    "Description", "clib.neuron.secname Representation of C++ function secname."); % Modify help description values as needed.');
    change_lines(end+1) = struct(...
        'from', '%defineArgument(secnameDefinition, "input1", "clib.neuron.Section", "input", 1); % <MLTYPE> can be "clib.neuron.Section", or "clib.array.neuron.Section"', ...
        'to', 'defineArgument(secnameDefinition, "input1", "clib.neuron.Section", "input", 1); % <MLTYPE> can be "clib.neuron.Section", or "clib.array.neuron.Section"');
    change_lines(end+1) = struct(...
        'from', '%defineOutput(secnameDefinition, "RetVal", "string", "nullTerminated", "DeleteFcn", <DELETER>); % Specify <DELETER> or remove the "DeleteFcn" option', ...
        'to', 'defineOutput(secnameDefinition, "RetVal", "string", "nullTerminated"); % Specify <DELETER> or remove the "DeleteFcn" option');
    change_lines(end+1) = struct(...
        'from', '%validate(secnameDefinition);', ...
        'to', 'validate(secnameDefinition);');
    % - the attribute obj.ctemplate.sym.name is a nullTerminated string
    change_lines(end+1) = struct(...
        'from', '%addProperty(SymbolDefinition, "name", <MLTYPE>, <SHAPE>, ... % <MLTYPE> can be "clib.array.neuron.Char","int8","string", or "char"', ...
        'to', 'addProperty(SymbolDefinition, "name", "string", "nullTerminated", ... % <MLTYPE> can be "clib.array.neuron.Char","int8","string", or "char"');
    change_lines(end+1) = struct(...
        'from', '%    "Description", "<MLTYPE>    Data member of C++ class Symbol."); % Modify help description values as needed.', ...
        'to', '    "Description", "string Data member of C++ class Symbol."); % Modify help description values as needed.');

%addProperty(SymbolDefinition, "name", <MLTYPE>, <SHAPE>, ... % <MLTYPE> can be "clib.array.neuron.Char","int8","string", or "char"
%    "Description", "<MLTYPE>    Data member of C++ class Symbol."); % Modify help description values as needed.


    func_replace_strings("defineneuron.m", "defineneuron.m", change_lines);

    % Build the library interface.
    build(defineneuron);
end

function [] = func_replace_strings(InputFile, OutputFile, ChangeStrings)
    % read whole model file data into cell array
    fid = fopen(InputFile);
    data = textscan(fid, '%s', 'Delimiter', '\n');
    data = data{1};
    fclose(fid);
    % modify the cell array
    % find the position where changes need to be applied and insert new data
    for i = 1:length(data)
        for j = 1:length(ChangeStrings)
            SearchString = ChangeStrings(j).from;
            tf = strcmp(data{i}, SearchString); % search for this string in the array
            if tf == 1
                data{i} = ChangeStrings(j).to; % replace with this string
            end
        end
    end
    % write the modified cell array into the text file
    fid = fopen(OutputFile, 'w');
    for i = 1:length(data)
        fprintf(fid, '%s\n', char(data{i}));
    end
    fclose(fid);
end

function compiler_exists = check_compiler(lang, shortname)
    arguments
        lang;
        shortname='';
    end
    confs = mex.getCompilerConfigurations;
    compiler_exists = false;
    for i = 1:length(confs)
        conf = confs(i);
        if strcmp(conf.Language, lang)
            if ~isempty(shortname)
                compiler_exists = strcmp(shortname, conf.ShortName);
            else
                compiler_exists = true;
            end
        end
    end
end
