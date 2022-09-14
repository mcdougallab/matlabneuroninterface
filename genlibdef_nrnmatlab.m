% Create definition file for NEURON library.
path_h = "nrnmatlab.h";
path_a = "bin/libnrniv.a";

clibgen.generateLibraryDefinition(path_h, Libraries=path_a, ...
    OverwriteExistingDefinitionFiles=true);