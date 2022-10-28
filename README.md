# NEURON Toolbox

Interface for connecting NEURON and MATLAB (on Windows, for MATLAB R2022a+).

This exploration branch is intended to explore the possibilities for 
connecting the two tools at a low level (C/C++) and avoid any third-party 
dependencies (e.g. work here will not require Python).

MATLAB is a registered trademark of The MathWorks, Inc. 

## Usage

First, make sure NEURON for Windows is installed (see http://neuron.yale.edu/).

To get the toolbox working on your machine, run the MATLAB scripts in the following order:
- **setup0_paths** 
    - to add the appropriate directories to your path (you might need to
      change the NEURON installation directory)
- **setup1_define**
    - to generate the library definition file
    - in this file, you will need to adapt & uncomment:
        - the function get_vector_vec: `<SHAPE>` is "len"
        - the Section attribute pt3d: `<MLTYPE>` is "clib.array.neuron.Pt3d", `<SHAPE>` is "npt3d"
        - (testing: the function new_section: add as defineOutput() arguments `"DeleteFcn", "matlab_delete_section"`)
- **setup2_build**
    - to build the library interface

Then, you can test the toolbox by running:
- **example_run** 
    - to initialize a Neuron session and call some top-level functions from the library
- **example_vector** 
    - to create a Vector object and calculate some properties
- **example_acpot** 
    - to generate an action potential
- **example_morph** 
    - to generate a morphology by connecting different Sections

**example_acpot** should result in:

![Action potential](doc/acpot.jpg)

## Notes

We use clibgen with MinGW64, and give it a .a static library file, 
which is included in bin/.

Hence this version only works on Windows (for now) for MATLAB versions 
R2022a and up; at this version support for .a static libraries was added. 

To convert the libnrniv.dll file to a static library we used the following
steps:
- We can see the libnrniv.dll contents with `dumpbin /exports bin/libnrniv.dll`
- All the exports listed there were saved to bin/libnrniv.def
- The DLL can then be converted to a .a file with `dlltool -d bin/libnrniv.def -D bin/libnrniv.dll -l bin/libnrniv.a`
- dlltool.exe can be found (for me) at C:\ProgramData\MATLAB\SupportPackages\R2022a\3P.instrset\mingw_w64.instrset\bin\dlltool.exe

