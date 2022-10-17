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
            self.ic = clib.neuron.get_IClamp(loc);
        end

        % Generic set/get methods
        function set_pp_property(self, name, val)
            clib.neuron.set_pp_property(self.ic, name, val);
        end
        function value = get_pp_property(self, name)
            value = clib.neuron.set_pp_property(self.ic, name, val);
        end

        % Individual set/get methods
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