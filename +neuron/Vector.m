classdef Vector < neuron.Object
% Vector Class for recording quantities such as time and voltage.
    
    methods

        function self = Vector(obj)
        % Initialize Vector
        %   Vector(obj) constructs a Matlab wrapper for a Neuron vector
        %   (obj).
            self = self@neuron.Object("Vector", obj);
        end

        function vec = get_vec(self)
        % Access C++ Vector object.
        %   vec = get_vec()
            vec = self.obj;
        end

        function arr = data(self)
        % Access Vector data.
        %   arr = data()
            arr = clib.neuron.get_vector_vec(self.obj, self.length());
        end
        
        function value = length(self)
        % Get Vector data length.
        %   value = length()
            value = self.call_method_hoc('size', 'double');
        end

        function arr = double(self)
        % Access Vector data as Matlab doubles.
        %   arr = double()
            vec_len = self.length();
            arr = zeros(1, vec_len);
            vec_data = self.data();
            for i=1:vec_len
                arr(i) = vec_data(i);
            end
        end

    end
end