# NEURON Toolbox

Interface for connecting NEURON and MATLAB.

This exploration branch is intended to explore the possibilities for 
connecting the two tools at a low level (C/C++) and avoid any third-party 
dependencies (e.g. work here will not require Python).

MATLAB is a registered trademark of The MathWorks, Inc. 

## Usage

Run the MATLAB scripts in the following order:
- genlibdef_nrnmatlab
    - in the resulting .mlx file, it is advised to comment out the code
      block containing `hoc_pushx` as we do not need to be able to call
      this function externally.
- build_nrnmatlab
- run_nrnmatlab

Results are written to stdout.txt.

## Notes

### Creating the .a static library file

We use clibgen with MinGW64, and give it a static library (a .a file). To
convert the libnrniv.dll file to a static library:
- We can see the libnrniv.dll contents with `dumpbin /exports bin/libnrniv.dll`
- All the exports listed there were saved to bin/libnrniv.def
- The DLL can then be converted to an .a file with `dlltool -d bin/libnrniv.def -D bin/libnrniv.dll -l bin/libnrniv.a`
- dlltool.exe can be found (for me) at C:\ProgramData\MATLAB\SupportPackages\R2022a\3P.instrset\mingw_w64.instrset\bin\dlltool.exe

