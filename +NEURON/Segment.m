classdef Segment
    properties (GetAccess = {?NEURON.IClamp})
        s
    end
    properties (Dependent)
        diam
        v
        v_ptr
    end
    methods
        function obj = Segment(wrapped_segment)
            obj.s = wrapped_segment;
        end
        function value = get.diam(obj)
            value = obj.s.diam;
        end
        function obj = set.diam(obj, value)
            obj.s.diam = value;
        end
        function value = get.v(obj)
            value = obj.s.v;
        end
        function obj = set.v(obj, value)
            obj.s.v = value;
        end
        function value = get.v_ptr(obj)
            value = NEURON.Pointer(py.neuronwrapper.get_ptr(obj.s, "v"));
        end
    end
end