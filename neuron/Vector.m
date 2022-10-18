% Vector class for recording quantities such as time and voltage.

classdef Vector < dynamicprops

    properties (Access=private)
        vec
        method_list
    end
    
    methods

        function self = Vector(n)
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

        function value = size(self)
        % Get Vector data size.
            value = clib.neuron.vector_double_method(self.vec, 'size');
        end

        function arr = data(self)
        % Access Vector data.
            arr = clib.neuron.get_vector_vec(self.vec, self.size());
        end

        function record(self, ptr)
        % Record some quantity by providing a NrnRef pointer to that quantity.
            clib.neuron.record(self.vec, ptr);
        end

        function value = hoc_get(self, method)
        % Call method by passing method name to HOC lookup.
        
            % Check if method exists; if not, show list of available methods.
            if any(strcmp(self.method_list, method+":270"))
                value = clib.neuron.vector_double_method(self.vec, method);
            else
                disp("Method '" + method + "' not found.");
                disp("Call Vector.list_methods() to see all methods.");
                value = NaN;
            end
        end

        function list_methods(self)
        % List all available methods to be called using HOC lookup.
            disp("For now, only methods with type 270 can be called.");
            for i=1:length(self.method_list)
                mth = self.method_list(i).split(":");
                disp("Name: " + mth(1) + ", type: " + mth(2));
            end
        end

        function varargout = subsref(self, S)
        % If a method is called, but it is not listed above, try to run it
        % by calling self.hoc_get().
            try
                [varargout{1:nargout}] = builtin('subsref', self, S);
            catch
                [varargout{1:nargout}] = hoc_get(self, S(1).subs);
            end
        end

    end
end