from neuron import h

myobjs = {}
count = 0

# these things are not to be wrapped
_dont_wrap = [str, float, int, list]


def _wrap(obj):
    for kind in _dont_wrap:
        if isinstance(obj, kind):
            return obj
    return Wrapper(obj)


class Wrapper:
    def __init__(self, obj):
        global count
        myobjs[count] = obj
        self._obj = count
        count += 1

    def call(self, name, *args, **kwargs):
        # have to unwrap any wrapped args and then rewrap if necessary
        myargs = [
            arg if not isinstance(arg, Wrapper) else myobjs[arg._obj] for arg in args
        ]
        result = getattr(myobjs[self._obj], name)(*myargs, **kwargs)
        return _wrap(result)

    def get(self, name):
        return _wrap(getattr(myobjs[self._obj], name))

    def set(self, name, value):
        setattr(myobjs[self._obj], name, value)

    def __del__(self):
        myobjs[self._obj] = None
        self._obj = None


def Section(*args, **kwargs):
    return h.Section(*args, **kwargs)


def load_file(*args, **kwargs):
    return h.load_file(*args, **kwargs)


def Vector(*args, **kwargs):
    return Wrapper(h.Vector(*args, **kwargs))


def IClamp(*args, **kwargs):
    return Wrapper(h.IClamp(*args, **kwargs))


def finitialize(*args, **kwargs):
    return h.finitialize(*args, **kwargs)


def continuerun(*args, **kwargs):
    h.load_file("stdrun.hoc")
    return h.continuerun(*args, **kwargs)


def get_t_ptr():
    return Wrapper(h._ref_t)


def get_pointer_value(obj):
    return myobjs[obj._obj][0]


def set_pointer_value(obj, value):
    myobjs[obj._obj][0] = value


def set_nseg(section, nseg):
    section.nseg = int(nseg)


def get_ptr(segment, name):
    return Wrapper(getattr(segment, "_ref_" + name))


def get_global(name):
    return _wrap(getattr(h, name))


def set_global(name, value):
    setattr(h, name, value)


def call_neuron_function(name, *args, **kwargs):
    return getattr(h, name)(*args, **kwargs)
