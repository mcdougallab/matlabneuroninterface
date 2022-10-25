classdef IClamp
% IClamp Current clamp class
    properties (Access=private)
        ic      % C++ IClamp object
    end
    properties (Dependent)
        del     % Delay.
        dur     % Duration.
        amp     % Amplitude.
    end
    methods
        function self = IClamp(sec, loc)
        % Construct current clamp on a section (sec) at a location (loc) between 0 and 1.
        %   IClamp(sec, loc)
            clib.neuron.nrn_pushsec(sec.get_sec());
            self.ic = clib.neuron.get_IClamp(loc);
            clib.neuron.nrn_sec_pop();
        end

        function delete(self)
        % Destructor for IClamp.
        %   delete()
            clib.neuron.hoc_obj_unref(self.ic);
            clibRelease(self.ic)
        end

        function ic = get_ic(self)
        % Return the C++ IClamp object.
        %   ic = get_ic() 
            ic = self.ic;
        end
        function set_pp_property(self, prop, val)
        % Generic set method, set IClamp property (prop) to value (val).
        %   set_pp_property(prop, val)
            clib.neuron.set_pp_property(self.ic, prop, val);
        end
        function value = get_pp_property(self, prop)
        % Generic get method for property (prop).
        %   value = get_pp_property(prop)
            value = clib.neuron.set_pp_property(self.ic, prop, val);
        end

        % Get/set dependent properties.
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