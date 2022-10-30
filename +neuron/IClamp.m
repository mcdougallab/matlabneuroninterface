classdef IClamp < neuron.Object
% IClamp Current clamp class
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
            neuron.hoc_push(loc);
            sym = clib.neuron.hoc_lookup("IClamp");
            obj = clib.neuron.hoc_newobj1(sym, 1);
            clib.neuron.nrn_sec_pop();
            self = self@neuron.Object("IClamp", obj);
        end

        function ic = get_ic(self)
        % Return the C++ IClamp object.
        %   ic = get_ic() 
            ic = self.obj;
        end
        function set_pp_property(self, prop, val)
        % Generic set method, set IClamp property (prop) to value (val).
        %   set_pp_property(prop, val)
            clib.neuron.set_pp_property(self.obj, prop, val);
        end
        function value = get_pp_property(self, prop)
        % Generic get method for property (prop).
        %   value = get_pp_property(prop)
            value = clib.neuron.set_pp_property(self.obj, prop, val);
        end

        % Get/set dependent properties.
        % TODO: these can be dynamically generated also; all these
        % properties have Neuron type 311.
        function set.del(self, val)
            clib.neuron.set_pp_property(self.obj, "del", val);
        end
        function value = get.del(self)
            value = clib.neuron.get_pp_property(self.obj, "del");
        end
        function set.dur(self, val)
            clib.neuron.set_pp_property(self.obj, "dur", val);
        end
        function value = get.dur(self)
            value = clib.neuron.get_pp_property(self.obj, "dur");
        end
        function set.amp(self, val)
            clib.neuron.set_pp_property(self.obj, "amp", val);
        end
        function value = get.amp(self)
            value = clib.neuron.get_pp_property(self.obj, "amp");
        end
    end
end