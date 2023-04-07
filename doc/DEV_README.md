# NEURON Toolbox for MATLAB: developer's readme

## Static library file

We use clibgen with MinGW64, and give it a .a static library file, 
which is included in `source/`.

Hence this version only works on Windows (for now) for MATLAB versions 
R2022a and up; at this version support for .a static libraries was added. 

To convert the `libnrniv.dll` file in the NEURON `bin` directory 
(default `C:\nrn\bin\libnrniv.dll`) to a static library we used the following
steps:
- We can see the libnrniv.dll contents with `objdump -x C:\nrn\bin\libnrniv.dll`, 
  these were saved to `source\objdump.txt`
- All the exports listed between the lines `[Ordinal/Name Pointer] Table` and 
  `The Function Table (interpreted .pdata section contents)` were saved to 
  `source\libnrniv.def` (there is a (slow) batch script to do this at 
  `source\get_exports.bat`)
- The DLL can then be converted to a .a file with `dlltool -d source\libnrniv.def 
  -D C:\nrn\bin\libnrniv.dll -l source\libnrniv.a`
- If you installed MinGW within MATLAB (R2022a, in this case), the standard 
  directory for objdump.exe and dlltool.exe is 
  `C:\ProgramData\MATLAB\SupportPackages\R2022a\3P.instrset\mingw_w64.instrset\x86_64-w64-mingw32\bin\`

In other words, for default NEURON and MATLAB 2022a directories, the static library can be made by running:

```
cd source

C:\ProgramData\MATLAB\SupportPackages\R2022a\3P.instrset\mingw_w64.instrset\x86_64-w64-mingw32\bin\objdump -x C:\nrn\bin\libnrniv.dll > objdump.txt

.\get_exports.bat

C:\ProgramData\MATLAB\SupportPackages\R2022a\3P.instrset\mingw_w64.instrset\x86_64-w64-mingw32\bin\dlltool -d libnrniv.def -D C:\nrn\bin\libnrniv.dll -l libnrniv.a
```

## Code structure

### Dynamic Neuron variables, functions an objects

NEURON variables, functions and objects are created dynamically. This works 
by making the Neuron class a subclass of `dynamicprops`, allowing us to
pass the name of whichever variable, function or object the user is calling to 
`clib.neuron.hoc_lookup` as a string. `clib.neuron.hoc_lookup` returns a 
`clib.neuron.Symbol` pointing to the correct variable, function or object. 
Depending on the Neuron type, this `clib.neuron.Symbol` can be passed to:

```matlab
clib.neuron.ref             % Variables
clib.neuron.hoc_call_func   % Functions
clib.neuron.hoc_newobj1     % Objects
```

Moreover, a Neuron function can expect some number of arguments,
which it will take from the Neuron stack machine. These arguments
need to be placed on the stack before calling the function, using
`neuron.push_hoc`. Output can be read by popping items off the stack
with `neuron.pop_hoc`. If the user provides
the incorrect number or types of input arguments, or tries to pop
output off the stack if there is none, the code might crash.

### Neuron Objects

A Neuron `clib.neuron.Object` is wrapped by MATLAB in the class 
`neuron.Object`. It has variables and methods, which are also 
generated dynamically using a `dynamicprops` subclassing construction.
Object variables and methods can be displayed using `list_methods`:

```matlab
v = n.Vector();
v.list_methods();
```

Watch out: if the user provides
the incorrect number or types of input arguments, the code might crash! We
hope to fix this behavior in NEURON 9, in which error handling will be updated.

Some Neuron Objects are defined __on__ a Section (e.g. IClamps); for these Objects, 
the constructor takes that Section as a first argument. These arguments are handled in
`Neuron.hoc_new_obj()`, which takes care of pushing and popping the Section.

The C++ object can be accessed with:

```matlab
Cpp_obj = v.get_obj();
```

Keep in mind that not all C++ object attributes are recognized by
MATLAB: it cannot understand unions, for example. In other words, not all
Neuron data types can be accessed directly from MATLAB.

### Sections

The `neuron.Section` class is the most straightforward MATLAB class in 
terms of implementation. Its methods and attributes are not generated 
dynamically.

```matlab
main = n.Section("main");       % Make main Section
branch = n.Section("branch");   % Make branch
branch.connect(0, main, 1);     % Connect start of branch to end of main
n.topology();                   % Display resulting topology
```

For calls to some top-level variables, functions or objects, it is
necessary to put a Section on the stack first. For example,
before attaching an IClamp to a Section, we need to first push the 
Section onto the stack with `clib.neuron.nrn_pushsec`. 
After creating the IClamp, we must not forget to run 
`clib.neuron.nrn_sec_pop` to take the Section off the stack again.
The `neuron.Neuron` class takes care of this automatically
(see `neuron.Neuron.hoc_new_obj`) if the user provides a Section
as input.

### NrnRef

The class `clib.neuron.NrnRef` contains a pointer to a Neuron variable, 
and was added to make sure MATLAB handles pointers correctly. 
The NrnRef can be given to `neuron.hoc_push` to put the pointer
on the Neuron stack.

The variable itself can be set or read with:

```matlab
t = n.ref("t");     % n.ref returns an NrnRef to a top-level variable
t.set(3.14);        % Sets the variable; equivalent to n.t = 3.14;
disp(t.get());      % Display the variable
```

## Neuron types

Top-level:
- 263: double variables (e.g. t, dt) — some that are global and some that are dependent on 
  the currently accessed section (e.g. L)
- 280: functions that return a double (e.g. finitialize and fadvance return 1.0 on success)
- 296: functions that return a char**
- 325: classes (e.g. IClamp and Vector)

Section related:
- 311: range variables (e.g. v)
- 312: insertable biophysical mechanisms (e.g. hh, pas)

Object related:
- 311: object attribute
- 270: a method that returns a double
- 329: a method that returns an object
- 330: a method that returns a string

Vector related:
- 264: math functions that return a double (these are all functions of 1 variable), that can
  be applied on the vector data

## Useful links

- [Creating a definition file](https://nl.mathworks.com/help/matlab/ref/clibgen.generatelibrarydefinition.html)
- [MATLAB/C++ data type mapping](https://nl.mathworks.com/help/matlab/matlab_external/matlab-to-c-data-type-mapping.html)
- [Lifetime management](https://nl.mathworks.com/help/matlab/matlab_external/memory-management-for-c-objects-in-matlab.html)
- [Releasing C++ memory](https://nl.mathworks.com/help/matlab/ref/clibrelease.html?s_tid=doc_ta)
- [Dynamic methods with subsref](https://nl.mathworks.com/matlabcentral/answers/59026-is-it-possible-to-dynamically-add-methods-to-an-object-or-to-build-a-generic-method-that-catches-a)
- [dynamicprops](https://nl.mathworks.com/help/matlab/ref/dynamicprops-class.html)
- [Set/get methods for dynamicprops](https://nl.mathworks.com/matlabcentral/answers/48831-set-methods-for-dynamic-properties-with-unknown-names?s_tid=answers_rc1-2_p2_MLT)