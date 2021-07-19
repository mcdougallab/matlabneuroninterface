classdef IClamp
    properties (Dependent)
        amp
        delay
        dur
    end
    properties (Access = private)
        ic
    end
    methods
        function obj = IClamp(seg)
            obj.ic = py.neuronwrapper.IClamp(seg.s);
        end
        function value = get.amp(obj)
            value = obj.ic.get("amp");
        end
        function value = get.delay(obj)
            value = obj.ic.get("delay");
        end
        function value = get.dur(obj)
            value = obj.ic.get("dur");
        end
        function obj = set.amp(obj, value)
            obj.ic.set("amp", value);
        end
        function obj = set.delay(obj, value)
            obj.ic.set("delay", value);
        end
        function obj = set.dur(obj, value)
            obj.ic.set("dur", value);
        end
    end
end

