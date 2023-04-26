# NEURON Toolbox for MATLAB

> :warning: For now, only Windows with MinGW is supported.

The NEURON Toolbox provides a MATLAB API to NEURON, using the MATLAB 
provided clibgen and clib packages to connect MATLAB and NEURON.

The [NEURON simulation environment](https://www.neuron.yale.edu/) is used 
in laboratories and classrooms around the world for building and using 
computational models of neurons and networks of neurons.

About this toolbox:

- The +neuron package defines the MATLAB API to NEURON. All calls to 
  NEURON from MATLAB should only use methods and properties exposed by 
  the classes in this package and should not directly use clib.neuron. 
  This is because the +neuron package takes care of proper initialization 
  of NEURON, and correct cleanup of NEURON objects.
- With clib, the NEURON shared library can be used through the clibgen 
  generated wrapper interface. The functions and variables exposed in the 
  wrapper interface can be used directly from MATLAB, e.g. it is possible 
  to call the NEURON function nrn_sec_pop from MATLAB with 
  `clib.neuron.nrn_sec_pop()`.
- With clibgen a MATLAB interface to the NEURON library is built. This 
  results in a wrapper shared library. Prebuilt wrappers for certain 
  Operating System and Compiler combinations may be provided.
    - To generate the interface, the underlying library should preferably 
      expose an API in a header file. Since NEURON itself does not provide 
      a C or C++ API that is directly useable in clibgen, the MATLAB-NEURON 
      project also contains header and C++ files that define a C++ API, 
      containing the NEURON functionality that needs to be available from 
      MATLAB.


MATLAB is a registered trademark of The MathWorks, Inc. 

For more detailed technical information about e.g. code structure, see [doc/DEV_README.md](doc/DEV_README.md).

## Usage

### Setup

First, make sure **NEURON 9** for Windows is installed (see http://neuron.yale.edu/).
Also make sure to set MinGW-w64 as your MEX C++ compiler; for more information about this, run `mex -setup cpp` in MATLAB.

To get the toolbox working on your machine, run the MATLAB scripts in the following order:
- **setup** 
    - to add the appropriate directories to your path (you might need to
      change the hardcoded NEURON installation directory)
    - **this script needs to be run every time a new MATLAB session is started**
- **utils.build_interface**
    - to build the library interface (neuron/neuronInterface.dll)
    - **this script needs to be run only once to generate the library interface**,
      it only needs to be re-run if the interface changes (for example when using a newer Neuron version)
    - please note: you need administrator rights to run build_interface
      (i.e. you need to run MATLAB as administrator)

### Example scripts

A comprehensive example live script, encompassing the smaller examples and providing additional explanation, can be found at **examples/example_livescript.mlx**.

Smaller example scripts are available at:
- **examples/example_run.m** 
    - to initialize a Neuron session and call some top-level functions from the library
- **examples/example_vector.m** 
    - to create a Vector object and calculate some properties
- **examples/example_morph.m** 
    - to generate a morphology by connecting different Sections, and add 3D points to them
- **examples/example_crash.m** 
    - to cause a :warning: crash by causing a method with the wrong arguments
- **examples/example_acpot.m** 
    - to generate an action potential

**example_acpot** should result in:

![Action potential](doc/acpot.jpg)

### Basic API usage

The main Neuron class can be found at `neuron.Neuron`. We can
initialize a Neuron session by instantiating it:

```matlab
n = neuron.Neuron();
```

Now all top-level variables, functions and classes can be accessed
using this object. The available variables, functions and classes, as 
well as their Neuron types can be displayed with:

```matlab
n.list_functions();
```

Top-level variables, functions and objects can be called directly. E.g.:

```matlab
disp(n.t);                  % Display the time
n.fadvance();               % Advance by one timestep
v = n.Vector();             % Create a Vector object
```

If you create an object like a Vector, you can see a list of its 
properties and methods with:

```matlab
v.list_methods();
```

### Testing

Run the tests with:

```matlab
runtests tests
```

### Differences with Python NEURON interface

A non-exhaustive list:
- `size(vector)` returns  an array `[1 N]` with `N == length(vector)`, 
  as is customary in MATLAB. In Python, `size(vector)` is a scalar.
- When iterating over segments we use `section.segments()`, which returns
  a cell array with Segment objects. In Python, we can simply write 
  `for segment in section`.
- Call chaining is not (yet) always available in MATLAB. As such, we cannot
  use `t = n.Vector().record(ref);`; instead we have to write
  `t = n.Vector(); t.record(ref);`. This is due to the way dynamic function
  calls are setup with `subsref`.
