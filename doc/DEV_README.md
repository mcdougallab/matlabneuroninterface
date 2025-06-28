# NEURON Toolbox for MATLAB: developer's readme

:warning: We no longer use `clib`, so any references to such in the below are out of date.

## Code structure

### Dynamic Neuron variables, functions an objects

NEURON variables, functions and objects are created dynamically. This works 
by making the NEURON class a subclass of `dynamicprops`, allowing us to
pass the name of whichever variable, function or object the user is calling to 
`hoc_lookup` as a string. `hoc_lookup` returns a 
`Symbol` pointing to the correct variable, function or object. 
Depending on the NEURON type, this `Symbol` can be passed to:

```matlab
clib.neuron.ref             % Variables
clib.neuron.hoc_call_func   % Functions
clib.neuron.hoc_newobj1     % Objects
```

Moreover, a NEURON function can expect some number of arguments,
which it will take from the NEURON stack machine. These arguments
need to be placed on the stack before calling the function, using
`neuron.push_hoc`. Output can be read by popping items off the stack
with `neuron.pop_hoc`. If the user provides
the incorrect number or types of input arguments, or tries to pop
output off the stack if there is none, the code might crash.

### NEURON Objects

A NEURON `neuron.Object` is wrapped by MATLAB in the class 
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

Some NEURON Objects are defined __on__ a Section (e.g. `IClamp` objects); for these Objects, 
the constructor takes that Section as a first argument. These arguments are handled in
`Neuron.hoc_new_obj()`, which takes care of pushing and popping the Section.

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
before attaching an `IClamp` to a Section, we need to first push the 
Section onto the stack with `nrn_pushsec`. 
After creating the `IClamp`, we must not forget to run 
`nrn_sec_pop` to take the Section off the stack again.
The `neuron.Session` class takes care of this automatically
(see `neuron.Session.hoc_new_obj`) if the user provides a Section
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

## NEURON types

These types are version-dependent and may not match your version of NEURON. 

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
- 271: a procedure (no return value)
- 329: a method that returns an object
- 330: a method that returns a string

Vector related:
- 264: math functions that return a double (these are all functions of 1 variable), that can
  be applied on the vector data

## Useful links

- [Lifetime management](https://nl.mathworks.com/help/matlab/matlab_external/memory-management-for-c-objects-in-matlab.html)
- [Releasing C++ memory](https://nl.mathworks.com/help/matlab/ref/clibrelease.html?s_tid=doc_ta)
- [Dynamic methods with subsref](https://nl.mathworks.com/matlabcentral/answers/59026-is-it-possible-to-dynamically-add-methods-to-an-object-or-to-build-a-generic-method-that-catches-a)
- [dynamicprops](https://nl.mathworks.com/help/matlab/ref/dynamicprops-class.html)
- [Set/get methods for dynamicprops](https://nl.mathworks.com/matlabcentral/answers/48831-set-methods-for-dynamic-properties-with-unknown-names?s_tid=answers_rc1-2_p2_MLT)