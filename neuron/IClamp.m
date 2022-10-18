% Current clamp class.

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
        function self = IClamp(loc)
        % Constructor for IClamp; create current clamp at a location
        % between 0 and 1 on the currently accessed section.
            self.ic = clib.neuron.get_IClamp(loc);
        end

        function set_pp_property(self, prop, val)
        % Generic set method, set IClamp property (prop) to value (val).
            clib.neuron.set_pp_property(self.ic, prop, val);
        end
        function value = get_pp_property(self, prop)
        % Generic get method for property (prop).
            value = clib.neuron.set_pp_property(self.ic, prop, val);
        end

        function self = set.del(self, val)
            clib.neuron.set_pp_property(self.ic, "del", val);
        end
        function value = get.del(self)
            value = clib.neuron.get_pp_property(self.ic, "del");
        end
        function self = set.dur(self, val)
            clib.neuron.set_pp_property(self.ic, "dur", val);
        end
        function value = get.dur(self)
            value = clib.neuron.get_pp_property(self.ic, "dur");
        end
        function self = set.amp(self, val)
            clib.neuron.set_pp_property(self.ic, "amp", val);
        end
        function value = get.amp(self)
            value = clib.neuron.get_pp_property(self.ic, "amp");
        end
    end
end