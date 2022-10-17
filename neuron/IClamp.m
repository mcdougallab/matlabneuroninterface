classdef IClamp
    properties (Access=public)
        ic
    end
    methods
        function obj = IClamp(loc)
            obj.ic = clib.neuron.get_IClamp(loc);
        end
        function set_pp_property(obj, name, val)
            clib.neuron.set_pp_property(obj.ic, name, val);
        end
    end
end