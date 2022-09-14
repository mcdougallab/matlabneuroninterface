# NEURON Toolbox

Interface for connecting NEURON and MATLAB.

This exploration branch is intended to explore the possibilities for 
connecting the two tools at a low level (C/C++) and avoid any third-party 
dependencies (e.g. work here will not require Python).

MATLAB is a registered trademark of The MathWorks, Inc. 

## Usage

Run the MATLAB scripts in the following order:
- **setup** to add the appropriate directories to your path
- **genlibdef_nrnmatlab** to generate the library definition file
- **build_nrnmatlab** to build the library interface
- **run_nrnmatlab** to call a function from the library

Results are written to stdout.txt.

## Notes

This version only works on Windows (for now). We use clibgen with MinGW64, 
and give it a static library (a .a file), which is included in bin/.

To convert the libnrniv.dll file to a static library we used the following
steps:
- We can see the libnrniv.dll contents with `dumpbin /exports bin/libnrniv.dll`
- All the exports listed there were saved to bin/libnrniv.def
- The DLL can then be converted to an .a file with `dlltool -d bin/libnrniv.def -D bin/libnrniv.dll -l bin/libnrniv.a`
- dlltool.exe can be found (for me) at C:\ProgramData\MATLAB\SupportPackages\R2022a\3P.instrset\mingw_w64.instrset\bin\dlltool.exe

