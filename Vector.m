classdef Vector
    properties (Dependent)
        size
    end
    properties (Access = private)
        vec
    end
    methods
        function obj = Vector
            obj.vec = py.neuronwrapper.Vector();
        end
        function value = get.size(obj)
            value = obj.vec.call("size");
        end
        function value = record(obj, ptr)
            obj.vec.call("record", ptr.ptr);
            value = obj;
        end
        function value = to_matlab(obj)
            value = double(py.array.array("d", obj.vec.call("to_python")));
%cellfun(@double, cell(obj.vec.call("to_python")));
        end
    end
end

