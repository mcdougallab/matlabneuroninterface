%% About definenrnmatlab.mlx
% This file defines the MATLAB interface to the library |nrnmatlab|.
%
% Commented sections represent C++ functionality that MATLAB cannot automatically define. To include
% functionality, uncomment a section and provide values for &lt;SHAPE&gt;, &lt;DIRECTION&gt;, etc. For more
% information, see <matlab:helpview(fullfile(docroot,'matlab','helptargets.map'),'cpp_define_interface') Define MATLAB Interface for C++ Library>.



%% Setup
% Do not edit this setup section.
function libDef = definenrnmatlab()
libDef = clibgen.LibraryDefinition("nrnmatlabData.xml");
%% OutputFolder and Libraries 
libDef.OutputFolder = "C:\Users\edo.vanveen\Documents\MATLAB\neuron";
libDef.Libraries = "bin/libnrniv.a";

%% C++ function |ivocmain_session| with MATLAB name |clib.nrnmatlab.ivocmain_session|
% C++ Signature: void ivocmain_session(int input1,char const * * input2,char const * * input3,int input4)
%ivocmain_sessionDefinition = addFunction(libDef, ...
%    "void ivocmain_session(int input1,char const * * input2,char const * * input3,int input4)", ...
%    "MATLABName", "clib.nrnmatlab.ivocmain_session", ...
%    "Description", "clib.nrnmatlab.ivocmain_session Representation of C++ function ivocmain_session."); % Modify help description values as needed.
%defineArgument(ivocmain_sessionDefinition, "input1", "int32");
%defineArgument(ivocmain_sessionDefinition, "input2", "string", "input", <SHAPE>);
%defineArgument(ivocmain_sessionDefinition, "input3", "string", "input", <SHAPE>);
%defineArgument(ivocmain_sessionDefinition, "input4", "int32");
%validate(ivocmain_sessionDefinition);

%% C++ function |hoc_oc| with MATLAB name |clib.nrnmatlab.hoc_oc|
% C++ Signature: int hoc_oc(char const * input1)
%hoc_ocDefinition = addFunction(libDef, ...
%    "int hoc_oc(char const * input1)", ...
%    "MATLABName", "clib.nrnmatlab.hoc_oc", ...
%    "Description", "clib.nrnmatlab.hoc_oc Representation of C++ function hoc_oc."); % Modify help description values as needed.
%defineArgument(hoc_ocDefinition, "input1", <MLTYPE>, "input", <SHAPE>); % <MLTYPE> can be "clib.array.nrnmatlab.Char","int8","string", or "char"
%defineOutput(hoc_ocDefinition, "RetVal", "int32");
%validate(hoc_ocDefinition);

%% C++ function |hoc_lookup| with MATLAB name |clib.nrnmatlab.hoc_lookup|
% C++ Signature: void * hoc_lookup(char const * input1)
%hoc_lookupDefinition = addFunction(libDef, ...
%    "void * hoc_lookup(char const * input1)", ...
%    "MATLABName", "clib.nrnmatlab.hoc_lookup", ...
%    "Description", "clib.nrnmatlab.hoc_lookup Representation of C++ function hoc_lookup."); % Modify help description values as needed.
%defineArgument(hoc_lookupDefinition, "input1", <MLTYPE>, "input", <SHAPE>); % <MLTYPE> can be "clib.array.nrnmatlab.Char","int8","string", or "char"
%defineOutput(hoc_lookupDefinition, "RetVal", <MLTYPE>, 1); % <MLTYPE> can be an existing typedef name for void* or a new typedef name to void*.
%validate(hoc_lookupDefinition);

%% C++ function |hoc_call_func| with MATLAB name |clib.nrnmatlab.hoc_call_func|
% C++ Signature: double hoc_call_func(void * input1,int input2)
%hoc_call_funcDefinition = addFunction(libDef, ...
%    "double hoc_call_func(void * input1,int input2)", ...
%    "MATLABName", "clib.nrnmatlab.hoc_call_func", ...
%    "Description", "clib.nrnmatlab.hoc_call_func Representation of C++ function hoc_call_func."); % Modify help description values as needed.
%defineArgument(hoc_call_funcDefinition, "input1", <MLTYPE>, <DIRECTION>, <SHAPE>); % <MLTYPE> can be primitive type, user-defined type, clib.array type, or a list of existing typedef names for void*.
%defineArgument(hoc_call_funcDefinition, "input2", "int32");
%defineOutput(hoc_call_funcDefinition, "RetVal", "double");
%validate(hoc_call_funcDefinition);

%% C++ function |hoc_pushx| with MATLAB name |clib.nrnmatlab.hoc_pushx|
% C++ Signature: void hoc_pushx(double input1)
hoc_pushxDefinition = addFunction(libDef, ...
    "void hoc_pushx(double input1)", ...
    "MATLABName", "clib.nrnmatlab.hoc_pushx", ...
    "Description", "clib.nrnmatlab.hoc_pushx Representation of C++ function hoc_pushx."); % Modify help description values as needed.
defineArgument(hoc_pushxDefinition, "input1", "double");
validate(hoc_pushxDefinition);

%% C++ function |run| with MATLAB name |clib.nrnmatlab.run|
% C++ Signature: int run(double finitialize_val)
runDefinition = addFunction(libDef, ...
    "int run(double finitialize_val)", ...
    "MATLABName", "clib.nrnmatlab.run", ...
    "Description", "clib.nrnmatlab.run Representation of C++ function run."); % Modify help description values as needed.
defineArgument(runDefinition, "finitialize_val", "double");
defineOutput(runDefinition, "RetVal", "int32");
validate(runDefinition);

%% Validate the library definition
validate(libDef);

end
