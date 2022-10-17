classdef IClamp
    properties (Access=private)
        ic
    end
    properties (Dependent)
        del
        dur
        amp
    end
    methods
        function obj = IClamp(loc)
            obj.ic = clib.neuron.get_IClamp(loc);
        end

        % Generic set/get methods
        function set_pp_property(obj, name, val)
            clib.neuron.set_pp_property(obj.ic, name, val);
        end
        function value = get_pp_property(obj, name)
            value = clib.neuron.set_pp_property(obj.ic, name, val);
        end

        % Individual set/get methods
        function obj = set.del(obj, val)
            clib.neuron.set_pp_property(obj.ic, "del", val);
        end
        function value = get.del(obj)
            value = clib.neuron.get_pp_property(obj.ic, "del");
        end
        function obj = set.dur(obj, val)
            clib.neuron.set_pp_property(obj.ic, "dur", val);
        end
        function value = get.dur(obj)
            value = clib.neuron.get_pp_property(obj.ic, "dur");
        end
        function obj = set.amp(obj, val)
            clib.neuron.set_pp_property(obj.ic, "amp", val);
        end
        function value = get.amp(obj)
            value = clib.neuron.get_pp_property(obj.ic, "amp");
        end
    end
end