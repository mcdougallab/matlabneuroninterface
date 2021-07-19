classdef Section
    properties (Access = private)
        s
    end
    properties (Dependent)
        L
        diam
        nseg
        Ra
    end
    methods
        function obj = Section(wrapped_section)
            obj.s = wrapped_section;
        end
        function value = insert(obj, name)
            obj.s.insert(name);
        end
        function value = get.L(obj)
            value = obj.s.L;
        end
        function obj = set.L(obj, value)
            obj.s.L = value;
        end
        function value = get.nseg(obj)
            value = obj.s.nseg;
        end
        function obj = set.nseg(obj, value)
            py.neuronwrapper.set_nseg(obj.s, value);
        end
        function value = get.Ra(obj)
            value = obj.s.Ra;
        end
        function obj = set.Ra(obj, value)
            obj.s.Ra = value;
        end
        function value = seg(obj, x)
            value = Segment(obj.s(x));
        end
        function value = get.diam(obj)
            value = obj.seg(0.5).diam;
        end
        function obj = set.diam(obj, value)
            for i = 1 : obj.nseg
                myseg = obj.seg((i - 0.5) / obj.nseg);
                myseg.diam = value;
            end
        end
    end
end