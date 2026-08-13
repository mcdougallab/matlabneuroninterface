# NEURON Toolbox for MATLAB: developer readme

This document describes the current implementation motifs in the MATLAB
bindings.

## Core architecture

### 1. Session bootstrap and singleton usage

Use `neuron.launch()` as the normal entry point.

- `launch()` initializes the MEX boundary (`neuron_api()`) and returns the
  singleton `neuron.Session.instance()`.
- `Session` constructor calls `setup_nrnmatlab(...)` and then builds dynamic
  symbol/method lists immediately.

### 2. Dynamic dispatch is `subsref`-first

Most external behavior is implemented by `subsref` on wrapper classes.

- `neuron.Session` and `neuron.Object` inherit from `dynamicprops`.
- Runtime symbol tables are split by return behavior (double, string, object,
  procedure/no-return, variable).
- Chained expressions are delegated through `neuron.chained_method(...)`.

Typical top-level flow for `n.somecall(...)`:

1. `Session.subsref` receives the expression.
2. `dynamic_call` classifies `somecall` using runtime lists.
3. Dispatch goes to:
   - `call_func_hoc(...)` for scalar/string/procedure functions
   - `hoc_new_obj(...)` for templates/objects
   - dynamic property get/set for top-level variables
4. Remaining chained indexing is handled by `chained_method`.

There is also a convenience path for raw HOC strings:

- `n('create soma')` is interpreted as `n.hoc('create soma')`.

### 3. Runtime type discovery (no hard-coded type numbers)

`neuron.TypeCodes` probes NEURON at runtime and stores discovered codes in
named fields such as `VAR`, `FUNCTION`, `PROCEDURE`, `TEMPLATE`, `RANGEVAR`,
`METHOD_OBFUNC`, `METHOD_STRFUNC`, and subtype fields like `USERDOUBLE`.

This avoids hard-coding parser enum integers and keeps dispatch resilient
across NEURON versions.

If discovery cannot resolve required fields, `TypeCodes.validate()` emits a
warning and affected dispatch branches may fail.

## Stack, argument, and context motifs

### 1. Sections are tracked separately from ordinary arguments

`neuron.stack.push_args(...)` returns `[nsecs, nargs]`:

- `nsecs`: how many sections were pushed to section context
- `nargs`: how many actual call arguments were pushed to the NEURON stack

`neuron.stack.pop_sections(nsecs)` is required to unwind section context after
the call.

This pattern is used by:

- `Session.call_func_hoc`
- `Session.hoc_new_obj`
- `Object.call_method_hoc`

### 2. Segment arguments push both section and position

`neuron.Segment` arguments are treated specially:

- push section context (parent section)
- push segment location `x` as a regular argument

This allows calls that conceptually target a segment while preserving proper
section state.

### 3. Nested call string-stack lifecycle

Function/method calls create a per-call string stack and always reset it in
both success and error paths.

Pattern:

- create with `nrn_create_string_stack`
- pass stack into argument-push helpers
- reset with `nrn_reset_string_stack`

### 4. Value-category push/pop helpers

`neuron.stack.hoc_push` handles category-based pushing:

- numeric/logical scalars
- strings/chars
- `neuron.Object`
- `neuron.NrnRef`
- null object sentinel

`neuron.stack.hoc_pop` pops by expected return kind (`double`, `string`,
`Object`, `void`) and wraps object returns into the appropriate MATLAB class
(`Vector`, `PlotShape`, `RangeVarPlot`, or generic `Object`).

## Wrapper class motifs

### 1. `neuron.Object`: runtime method/property classification

`neuron.Object` inspects class methods from NEURON and builds dynamic maps:

- steered/dynamic attributes
- point-process scalar properties
- point-process array properties (via `attr_array_map`)
- methods grouped by return kind (double/procedure/object/string)

All unknown dot calls that match discovered methods are routed through
`call_method_hoc(...)`.

### 2. `neuron.Section`: ownership-aware lifetime

`Section` tracks an `owner` flag:

- `owner = true` means MATLAB object destruction also deletes NEURON section
- `owner = false` means wrapper does not own the NEURON section lifetime

The constructor also discovers valid mechanism names and range variables from
runtime symbol tables.

### 3. `neuron.Segment`: lightweight section-local proxy

`Segment` stores `(parent_sec, x)` and provides:

- dynamic access to range variables at that location
- push semantics that combine section context + position

### 4. `neuron.NrnRef`: reference wrapper by referent class

References are wrapped as `neuron.NrnRef` and dispatched by `ref_class`
(`Vector`, `Symbol`, `ObjectProp`, `RangeVar`).

The important motif is semantic reference handling, not raw pointer arithmetic:
the wrapper routes get/set/push operations based on what is referenced.

### 5. `neuron.Vector`: MATLAB-friendly indexing shim

`Vector` is an `Object` subclass with heavy index-translation logic:

- MATLAB user-facing indexing is 1-based
- many NEURON vector internals are 0-based
- `subsref`/`subsasgn` adapt arguments and, where needed, temporarily adjust
  vector-valued index arguments before and after method calls

This is a unique and intentional compatibility layer.

### 6. Section collections

- `neuron.SectionList` wraps NEURON section lists and exposes `allsec()`.
- `allsec()` returns a `neuron.SectionArray` wrapper for consistent indexing.
- `SectionArray` is a light indexing container around section vectors.

## Resilience and refresh motifs

### 1. Dynamic symbol refresh on failed top-level dispatch

`Session.subsref` retries failed calls by rebuilding dynamic properties via
`fill_dynamic_props()`. This supports workflows where available symbols change
at runtime (for example after loading HOC).

### 2. Read-only internals guarded in `subsasgn`

Core wrapper internals are protected from reassignment and emit explicit errors
if modified from MATLAB.

## Callback motif

`neuron.FInitializeHandler` keeps a MATLAB-side persistent registry of handler
objects and registers callback hooks with unique function names in HOC space.

This bridges NEURON initialization callbacks back into MATLAB function handles.

## Quick code map

- Session dispatch: `+neuron/Session.m`
- Object dispatch and method calls: `+neuron/Object.m`
- Runtime type discovery: `+neuron/TypeCodes.m`
- Stack helpers: `+neuron/+stack/*.m`
- Section/segment wrappers: `+neuron/Section.m`, `+neuron/Segment.m`
- Reference wrapper: `+neuron/NrnRef.m`
- Vector index adaptation: `+neuron/Vector.m`
- Callback bridge: `+neuron/FInitializeHandler.m`

## Notes for future changes

- Preserve the `subsref` + dynamic-list dispatch model unless replacing it
  everywhere consistently.
- Avoid introducing hard-coded NEURON type integers.
- When adding new wrappers, define indexing semantics explicitly (MATLAB
  1-based vs NEURON 0-based) and test both scalar and chained calls.