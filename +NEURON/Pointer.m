classdef Pointer
    properties (Dependent)
        val
    end
    properties (GetAccess = {?NEURON.Vector})
        ptr
    end
    methods
        function obj = Pointer(ptr)
            obj.ptr = ptr;
        end
        function value = get.val(obj)
            value = py.neuronwrapper.get_pointer_value(obj.ptr);
        end
        function obj = set.val(obj, value)
            py.neuronwrapper.set_pointer_value(obj.ptr, value);
        end
    end
end

