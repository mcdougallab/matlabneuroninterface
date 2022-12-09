classdef Vector < neuron.Object
% Vector Class for recording quantities such as time and voltage.
    
    properties (SetAccess=protected, GetAccess=public)
        apply_func_list   % List of allowed built-in functions.
    end

    methods

        function self = Vector(obj)
        % Initialize Vector
        %   Vector(obj) constructs a Matlab wrapper for a Neuron vector
        %   (obj).
            self = self@neuron.Object("Vector", obj);

            self.apply_func_list = [];
            arr = split(clib.neuron.get_nrn_functions(), ";");
            arr = arr(1:end-1);

            % Add dynamic mechanisms and range variables.
            % See: doc/DEV_README.md#neuron-types
            for i=1:length(arr)
                var = split(arr(i), ":");
                if (var(2) == "264")
                    self.apply_func_list = [self.apply_func_list var(1)];
                end
            end

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

        function value = apply(self, varargin)
        % Apply built-in function to vector.
        %   value = apply(varargin)
            if length(varargin) ~= 1
                warning("Vector.apply() always takes a single argument.");
            elseif any(strcmp(self.apply_func_list, varargin{1}))
                value = call_method_hoc(self, "apply", "Object", varargin{1});
            else
                warning("Built-in function '"+varargin{1}+"' not found.");
                disp("Available built-in functions:")
                for i=1:self.apply_func_list.length()
                    disp("    "+self.apply_func_list(i));
                end
            end
            
        end

    end
end