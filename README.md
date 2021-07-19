# MATLAB - NEURON interface
Interface for connecting NEURON and MATLAB.

This branch uses Python as the bridge, with thin wrappers in both MATLAB and Python.

Only a limited subset of NEURON is currently supported; examine and run the matlab script [`neurondemo`](https://github.com/mcdougallab/matlabneuroninterface/blob/using-python/neurondemo.m) for an example of generating and plotting an action potential. Notably absent, any ability to connect sections together, although this can in principle be done using the same strategies as in the existing code.

![image](https://user-images.githubusercontent.com/6668090/126222850-7305cf56-d8b7-4620-9543-5a82a17cd084.png)


Everything may be accessed through an instance of the NEURON class.

Suppose `n = NEURON`. Then:

## Section
To construct a Section, specify a name, e.g.

    soma = n.Section("soma");

Each section (`sec` in the below) has certain properties:

    sec.L      % length in µm
    sec.diam   % diameter in µm (sets everything, but gets the value at the middle)
    sec.nseg   % number of segments (must be an integer >= 1)

To insert a distributed ion channel mechanism (NEURON comes with `"hh"` and `"pas"`) call `.insert` and specify the name as a string, e.g.

    sec.insert("hh")

To access a segment by normalized position (0 <= x <= 1), call `.seg` with the position as an argument, e.g.

    sec.seg(0.5)

## Segment
Segments are obtained by using a `Section` object's `.seg` method as above. If `seg` is such a Segment, it has three supported properties:

    seg.diam  % diameter in µm
    seg.v     % membrane potential
    seg.v_ptr % pointer to membrane potential (use with Vector.record)

## Pointer
Pointers may be obtained in a couple ways. A Pointer `ptr` has one public property:

    ptr.value  % the value pointed to; it may be read and set

## IClamp
An IClamp `ic` is a current clamp. Construct an IClamp by passing in a segment as in:

    ic = n.IClamp(soma.seg(0.5))

Every IClamp has three properties, all of which can be read and written:

    ic.amp     % amplitude (nA)
    ic.delay   % start time (ms)
    ic.dur     % duration (ms)

## Vector
A Vector `vec` is used to record a time series or other data. Construct a Vector via e.g.

    vec = n.Vector()

The interface currently supports the following methods:

    vec.record(ptr)       % record the value pointed to by ptr as the simulation advances
    vec.to_matlab()       % return a copy of the vector as a MATLAB array

Additionally, `vec` supports the following property:

    vec.size              % the number of elements in the vector

## Miscellaneous
Some functions are available at the top level:

    n.finitialize(vinit)  % initialize the simulation, setting initial potential to vinit
    n.fadvance()          % advance one timestep
    n.continuerun(tstop)  % continue until time tstop, measured in ms
    n.hoc(string)         % execute string as a HOC command

There are also global values:

    n.t                   % current simulation time (in ms); may be read and set
    n.dt                  % current time step (in ms); may be read and set
    n.celsius             % temperature (in celsius); may be read and set
    n.t_ptr               % a pointer to the current time; use this with Vector.record
