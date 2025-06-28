# NEURON Toolbox for MATLAB
[![View NEURON toolbox for MATLAB on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/135842-neuron-toolbox-for-matlab)

The NEURON Toolbox provides a MATLAB API to NEURON, via MEX and the NEURON C API, introduced in NEURON 9.

The [NEURON simulation environment](https://nrn.readthedocs.io/) is used
in laboratories and classrooms around the world for building and using
computational models of neurons and networks of neurons.

About this toolbox:

- The +neuron package defines the MATLAB API to NEURON. All calls to
  NEURON from MATLAB should only use methods and properties exposed by
  the classes in this package.
  This is because the +neuron package takes care of proper initialization
  of NEURON, and correct cleanup of NEURON objects.


MATLAB is a registered trademark of The MathWorks, Inc.

For more detailed technical information about e.g. code structure, see [doc/DEV_README.md](doc/DEV_README.md).

## Usage

### Setup

Before using the toolbox for the first time, go through the [first time only](#first-time) steps.

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

The main NEURON class can be found at `neuron.Session`. A (singleton) 
`neuron.Session` is returned upon calling the `neuron.launch()` function.

```matlab
n = neuron.launch();
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
runtests +tests
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

<a id="first-time"></a>
## First time only

Here the steps are given that need to be done only once to be able to use the toolbox.

1. Make sure NEURON 9 is installed (see https://nrn.readthedocs.io).
2. Linux and Mac: start Matlab from a bash shell with the correct PATH, `HOC_LIBRARY_PATH`. Matlab always needs to be started from such a shell, not just the first time only.
   - Get the directory where libnrniv is installed, within the NEURON installation folder.
     - If you installed NEURON via `pip`, you can do `import neuron; print(neuron.__file__)`. On my system, this displays `/Users/ramcdougal/anaconda3/envs/py313/lib/python3.13/site-packages/neuron/__init__.py`, which means libnrniv is at `/Users/ramcdougal/anaconda3/envs/py313/lib/python3.13/site-packages/neuron/.data/lib/libnrniv.dylib`
   - The environment variable `HOC_LIBRARY_PATH` should be set to the folder containing, e.g., `atoltool.hoc`; on my system, with libnrniv as above, this is `/Users/ramcdougal/anaconda3/envs/py313/lib/python3.13/site-packages/neuron/.data/share/nrn/lib/hoc/`
   - Get the directory where this toolbox is installed and put that on your MATLAB path
3. Update the paths in `source/neuron_api.cpp`
  - for the `#include` of `neuronapi.h`: in my computer as above, this is `/Users/ramcdougal/anaconda3/envs/py313/lib/python3.13/site-packages/neuron/.data/include/neuronapi.h`
  - for the definition of `neuron_handle`, that should use the path to `libnrniv.dylib` or system equivalent.
  - for the definition of `wrapper_handle` to this project folder and then `/libmodlreg.dylib` (mac) or system equivalent.
4. Compile the package: from the project folder, run:
  - `!gcc -shared -o libmodlreg.dylib source/modl_reg.c`
  - `mex CXXFLAGS="-std=c++17" source/neuron_api.cpp`
5. Check it works:
   - With the previous steps completed, run the matlab scripts **example_run** and **example_acpot** to check that the matlabneuroninterface works.
   - Linux and Mac, additionally: 
      - Run **example_loadfile** to check that the HOC_LIBRARY_PATH has been set correctly.
      - Run **example_mod** to check that the PATH is correct. If this example fails, update the PATH per the instructions in the example startup script.
