# NEURON Toolbox for MATLAB
[![View NEURON toolbox for MATLAB on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/135842-neuron-toolbox-for-matlab)

> :warning: This toolbox has specific requirements depending on operating system
> * Windows: Matlab R2022a or higher, MinGW compiler, and Administrator rights
> * Linux: Matlab R2023a or higher and GCC compiler
> * Mac: [Under Development] Matlab R2023a or higher, Intel Macs only and Clang compiler
>
> For the compiler used, the version should preferably match the exact version used
> to compile NEURON, as using a newer or older version could have different symbol name-mangling.

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

Before using the toolbox for the first time, go through the [first time only](#first-time) steps. On Windows, these steps need to be run from a Matlab session with Administrator rights.

Linux and Mac: To be able to use the toolbox, Matlab always needs to be started from an environment with specific environment variables, see [first time only](#first-time) for details. Also, output printed from within NEURON itself will show in the shell from which Matlab is started, instead of the Matlab command window.

In each Matlab session where you want to use the toolbox, run the script **setup.m**. Alternatively, add a call to this setup.m [in your startup.m file](https://www.mathworks.com/help/matlab/ref/startup.html).

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

The main Neuron class can be found at `neuron.Session`. A (singleton) 
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

1. Make sure NEURON is installed (see http://neuron.yale.edu/).
2. Linux and Mac: start Matlab from a bash shell with the correct PATH, HOC_LIBRARY_PATH and on Linux LD_LIBRARY_PATH, on Mac DYLD_LIBRARY_PATH. Matlab always needs to be started from such a shell, not just the first time only.
   - Get the directory where libnrniv is installed, within the NEURON installation folder
   - Get the directory where this toolbox is installed
   - Determine the value of matlabroot (https://nl.mathworks.com/help/matlab/ref/matlabroot.html)
   - Use these values to set the HOC_LIBRARY_PATH and LD_LIBRARY_PATH / DYLD_LIBRARY_PATH. Example shell scripts are available for [Linux](doc/example_startup_scripts/linux_matlab.sh) and [Mac](doc/example_startup_scripts/linux_matlab.sh). Within these scripts, replace `<..matlabroot..>`, `<..neuron-directory..>` and `<..matlabneuroninterface..>` with the correct directory paths.
   - Depending on how Neuron was installed, it may be that also the PATH variable needs to be updated. See item 6 'Check it works'.
3. Make sure to setup your MEX C++ compiler; for more information about this, run `mex -setup cpp` in MATLAB.
   - Windows: MinGW-w64
   - Linux: gcc
   - Mac: clang
4. Update neuron_lib_directory in +utils/Paths.m if needed.
5. Run the MATLAB scripts in the following order:
   - **setup**
      - This script needs to be run every time a new MATLAB session is started
      - It adds the appropriate directories to your path 
   - **utils.build_interface**
      - This script needs to be run once to generate the library interface, and only needs to be re-run if the interface changes (for example when using a newer Neuron version)
      - It builds the library interface (neuron/neuronInterface.*)
      - Please note: on Windows you need administrator rights to run build_interface
6. Check it works:
   - With the previous steps completed, run the matlab scripts **example_run** and **example_acpot** to check that the matlabneuroninterface works.
   - Linux and Mac, additionally: 
      - Run **example_loadfile** to check that the HOC_LIBRARY_PATH has been set correctly.
      - Run **example_mod** to check that the PATH is correct. If this example fails, update the PATH per the instructions in the example startup script.
