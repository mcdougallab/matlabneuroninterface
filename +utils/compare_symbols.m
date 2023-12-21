function [list_symbols, list_unused] = compare_symbols(optionals)
%% Compare the symbols that are needed, with the symbols as present in the
% compiled shared library, and with the symbols present in nrniv.
% Due to name mangling, there might be discrepancies if a different
% compiler version is used.
% Uses the nm utility to get the lists of symbols from the shared library
% files, or text files with the lists can be provided as input.
%
% Examples:
% [symbols_table, unused_symbols] = utils.compare_symbols()
% [symbols_table, unused_symbols] = utils.compare_symbols(compiled_symbols_file="./+utils/neuronInterface.txt", nrniv_symbols_file="./+utils/nrniv.txt")
arguments
    optionals.compiled_symbols_file (1,1) string = ""
    optionals.nrniv_symbols_file (1,1) string = ""
end

list_unused = string.empty;
this_dir = fileparts(mfilename('fullpath'));
needed_symbols_file = fullfile(utils.Paths.toolbox_directory(), "source", "neuron_dllimports.h");

if ismac
    lib_ext = ".dylib";
elseif isunix
    lib_ext = ".so";
else
    lib_ext = "";
end

% Create the files with the lists of symbols in the libraries
if optionals.compiled_symbols_file == ""
    compiled_symbols_file = fullfile(this_dir, "neuronInterface.txt");
    cmd = "nm '" + fullfile(utils.Paths.toolbox_lib_directory(), "neuronInterface" + lib_ext) + "' > '" + compiled_symbols_file + "'";
    status = system(cmd);
    if status
        error("system call failed")
    end
else
    compiled_symbols_file = optionals.compiled_symbols_file;
end
if optionals.nrniv_symbols_file == ""
    nrniv_symbols_file = fullfile(this_dir, "nrniv.txt");
    cmd = "nm '" + utils.Paths.libnrniv_file() + "' > '" + nrniv_symbols_file + "'";
    status = system(cmd);
    if status
        error("system call failed")
    end
else
    nrniv_symbols_file = optionals.nrniv_symbols_file;
end

% Get the symbols lists as one big char array
% For easier later regex search, make sure there is a newline at the start and end
compiled_content = [10 fileread(compiled_symbols_file) 10];
nrniv_content = [10 fileread(nrniv_symbols_file) 10];

%% Parse the needed_symbols_file
% Assume that lines starting with MANGLED
% and NON_MANGLED have a symbol that should be checked
possible_symbols = readlines(needed_symbols_file);
max_nr_symbols = length(possible_symbols);
varTypes = ["string", "logical", "string", "logical", "string"];
varNames = ["Symbol", "is_mangled", "Interface", "is_matching", "Nrniv"];
list_symbols = table('Size', [max_nr_symbols, length(varNames)], 'VariableTypes', varTypes, 'VariableNames', varNames);
for i = 1:max_nr_symbols
    line = possible_symbols(i);
    if contains(line, "Import functions for which name mangling goes awry")
        % TODO: something for the functions that we know are problematic,
        % for now they need to be manually checked
        break
    end
    if line.startsWith(["MANGLED","NON_MANGLED"])
        parts = line.split;
        if length(parts) ~= 3
            error("line in file starting with MANGLED cannot be split in exactly three parts, script needs to be adapted")
        elseif ~parts.endsWith(';')
            error("The third part of a line in file starting with MANGLED or NON_MANGLED does not end with ;, script needs to be adapted")
        end
        list_symbols.Symbol(i) = parts{3}(1:end-1);
        list_symbols.is_mangled(i) = line.startsWith("MANGLED");
    end
end
emptyrows = ismissing(list_symbols.Symbol);
list_symbols = list_symbols(~emptyrows,:);
nr_symbols = height(list_symbols);

%% Try to find the list of actual symbols in both shared libraries
% Use regex to search through full files at once
for i = 1:nr_symbols
    %% The symbol in our interface
    searchstr = list_symbols.Symbol(i);
    if isequal(searchstr, "hoc_pushs")
        % Workaround:
        % Because hoc_pushstr is also in the search list, will find two
        % symbols matching hoc_pushs. Use a negative-lookahead to exclude
        % the case where hoc_pushs is followed by tr.
        searchstr = "hoc_pushs(?!tr)";
    else
        searchstr = regexptranslate("escape", searchstr);
    end
    % full line containing ".*U .*searchstr.*"
    % With the U directly before the (name-mangled) symbol, since looking
    % for things that are coming from a different library
    expr = "[^\n\r]*" + "U \S*" + searchstr + "\S*";
    found = regexpi(compiled_content, expr, 'match');
    if length(found) > 1
        error("more than one match for symbol")
    elseif length(found) < 1
        list_unused(end+1) = list_symbols.Symbol(i); %#ok<AGROW>
        continue
    end
    % get the possibly name-mangled exact compiled name
    expr = "\S*" + searchstr + "\S*";
    found = regexpi(found{1}, expr, 'match');
    list_symbols.Interface(i) = string(found{1});

    %% The symbol in nrniv
    % First look for 'mangled' exact match
    searchstr = list_symbols.Interface(i);
    searchstr = regexptranslate("escape", searchstr);
    % exact match, so surrounded by whitespace
    expr = "\s" + searchstr + "\s";
    found = regexpi(nrniv_content, expr, 'match');
    if length(found) > 1
        error("more than one match for symbol")
    elseif length(found) < 1
        % Look for a differently mangled version
        searchstr = list_symbols.Symbol(i);
        searchstr = regexptranslate("escape", searchstr);
        % full line containing searchstr
        % TODO: This expr might need tweaking, this case has not come up
        % yet in test runs
        expr = "[^\n\r]*" + searchstr + "[^\n\r]*";
        found = regexpi(nrniv_content, expr, 'match');
        if length(found) > 1
            error("more than one match for symbol")
        end
    end
    if length(found) == 1
        % get the exact symbol name
        expr = "\S*" + searchstr + "\S*";
        found = regexpi(found{1}, expr, 'match');
        list_symbols.Nrniv(i) = string(found{1});
    end

    list_symbols.is_matching(i) = isequal(list_symbols.Nrniv(i), list_symbols.Interface(i));
end

end