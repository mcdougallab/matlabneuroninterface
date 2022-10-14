classdef Vector
    properties (Access=public)
        vec
    end
    methods
        function obj = Vector(n)
            if (nargin==1)
                obj.vec = clib.neuron.get_vector(n);
            else
                obj.vec = clib.neuron.get_vector(0);
            end
        end
        function value = size(obj)
            value = clib.neuron.vector_double_method(obj.vec, 'size');
        end

        % Prob need to check for all these properties if Vector.size() > 0
        function value = hoc_get(obj, method)
            value = clib.neuron.vector_double_method(obj.vec, method);
        end
        function value = mean(obj)
            value = clib.neuron.vector_double_method(obj.vec, 'mean');
        end
        function value = stdev(obj)
            value = clib.neuron.vector_double_method(obj.vec, 'stdev');
        end
        function value = sum(obj)
            value = clib.neuron.vector_double_method(obj.vec, 'sum');
        end
        function value = sumsq(obj)
            value = clib.neuron.vector_double_method(obj.vec, 'sumsq');
        end
        function arr = data(obj)
            vec_len = obj.size();
            arr = zeros(1, vec_len);
            vec_data = clib.neuron.get_vector_vec(obj.vec, vec_len);
            for i=1:vec_len
                arr(i) = vec_data(i);
            end
        end
        function record(obj, ptr)
            clib.neuron.record(obj.vec, ptr);
        end
    end
end