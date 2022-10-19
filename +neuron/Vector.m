classdef Vector < dynamicprops
% Vector Class for recording quantities such as time and voltage.

    properties (Access=private)
        vec             % C++ Vector object.
        method_list     % List of methods of the C++ object.
    end
    
    methods

        function self = Vector(n)
        % Initialize Vector
        %   Vector() constructs an empty vector
        %   Vector(n) constructs a Vector of length n

            % Upon initialization, get vector object and list of methods.
            self = self@dynamicprops;
            if (nargin==1)
                self.vec = clib.neuron.get_vector(n);
            else
                self.vec = clib.neuron.get_vector(0);
            end
            method_str = clib.neuron.get_class_methods("Vector");
            self.method_list = split(method_str, ";");
            self.method_list = self.method_list(1:end-1);
        end

        function delete(self)
        % Destroy the Vector object.
        %   delete()

            % Release self.vec C++ object.
            clibRelease(self.vec)
        end

        function value = size(self)
        % Get Vector data size.
        %   value = size()
            value = clib.neuron.vector_double_method(self.vec, 'size');
        end

        function arr = data(self)
        % Access Vector data.
        %   arr = data()
            arr = clib.neuron.get_vector_vec(self.vec, self.size());
        end

        function arr = double(self)
        % Access Vector data as Matlab doubles.
        %   arr = double()
            vec_len = self.size();
            arr = zeros(1, vec_len);
            vec_data = self.data();
            for i=1:vec_len
                arr(i) = vec_data(i);
            end
        end

        function record(self, nrnref)
        % Record some quantity by providing a NrnRef to that quantity.
        %   record(nrnref)
            clib.neuron.record(self.vec, nrnref);
        end

        function value = hoc_get_double(self, method, varargin)
        % Call method returning a double by passing method name (method) to HOC lookup, along with method arguments (varargin).
        %   value = hoc_get(method, varargin)
            
            % TODO: pass variable number of arguments (varargin) to C++
            try
                value = clib.neuron.vector_double_method(self.vec, method);
            catch  % TODO: if the above code fails, usually Matlab just crashes instead of catching some error.
                warning("'"+string(method)+"': number or type of arguments incorrect.")
            end

        end

        function list_methods(self)
        % List all available methods to be called using HOC lookup.
        %   list_methods()
            disp("For now, only methods with type 270 can be called.");
            for i=1:length(self.method_list)
                mth = self.method_list(i).split(":");
                disp("Name: " + mth(1) + ", type: " + mth(2));
            end
        end

        function varargout = subsref(self, S)
        % If a method is called, but it is not listed above, try to run it by calling self.hoc_get().

            % S(1).subs is method name;
            % S(2).subs is a cell array containing arguments.
            method = S(1).subs;

            if any(strcmp(self.method_list, method+":270"))
                [varargout{1:nargout}] = hoc_get_double(self, method, S(2).subs{:});
            else
                [varargout{1:nargout}] = builtin('subsref', self, S);
            end
        end

    end
end