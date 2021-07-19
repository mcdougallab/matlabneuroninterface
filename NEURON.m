classdef NEURON
    properties (Dependent)
        celsius
        t
        dt
        t_ptr
    end
    methods
        function value = Section(obj, name)
            value = Section(py.neuronwrapper.Section(name));
        end
        function value = fadvance(obj)
            value = py.neuronwrapper.call_neuron_function("fadvance");
        end
        function value = finitialize(obj, v_init)
            value = py.neuronwrapper.call_neuron_function("finitialize", v_init);
        end
        function value = continuerun(obj, tstop)
            value = py.neuronwrapper.continuerun(tstop);
        end
        function value = get.celsius(obj)
            value = py.neuronwrapper.get_global("celsius");
        end
        function obj = set.celsius(obj, value)
            py.neuronwrapper.set_global("celsius", value);
        end
        function value = get.t(obj)
            value = py.neuronwrapper.get_global("t");
        end
        function obj = set.t(obj, value)
            py.neuronwrapper.set_global("t", value);
        end
        function value = get.dt(obj)
            value = py.neuronwrapper.get_global("dt");
        end
        function obj = set.dt(obj, value)
            py.neuronwrapper.set_global("dt", value);
        end
        function value = get.t_ptr(obj)
            value = Pointer(py.neuronwrapper.get_t_ptr());
        end
        function value = hoc(obj, s)
            value = py.neuron.h(s);
        end
        function value = IClamp(obj, segment)
            value = IClamp(segment)
        end
        function value = Vector(obj)
            value = Vector()
        end
    end
end

