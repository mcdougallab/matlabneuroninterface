classdef Vector < dynamicprops
% Vector Class for recording quantities such as time and voltage.

    properties (Access=private)
        vec             % C++ Vector object.
        method_list     % List of methods of the C++ object.
    end
    
    methods

        function self = Vector(n, vec)
        % Initialize Vector
        %   Vector() constructs an empty vector
        %   Vector(n) constructs a Vector of length n
        %   Vector(n, vec) constructs a Vector from C++ vector object vec

            self = self@dynamicprops;
            if clib.neuron.isinitialized()
                % Upon initialization, get vector object and list of methods.
                if (nargin==1)
                    self.vec = clib.neuron.get_vector(n);
                elseif (nargin==2)
                    self.vec = vec;
                else
                    self.vec = clib.neuron.get_vector(0);
                end
                method_str = clib.neuron.get_class_methods("Vector");
                self.method_list = split(method_str, ";");
                self.method_list = self.method_list(1:end-1);
            else
                warning("Initialize a Neuron session before making a Vector.");
            end
        end

        function delete(self)
        % Destroy the Vector object.
        %   delete()

            % Release self.vec C++ object.
            if (class(self.vec) == "clib.neuron.Object")
                clibRelease(self.vec)
            end
        end

        function vec = get_vec(self)
        % Access C++ Vector object.
        %   vec = get_vec()
            vec = self.vec;
        end

        function arr = data(self)
        % Access Vector data.
        %   arr = data()
            arr = clib.neuron.get_vector_vec(self.vec, self.length());
        end
        
        function value = length(self)
        % Get Vector data length.
        %   value = length()
            value = call_method_hoc(self, 'size', 'double');
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

        function record(self, nrnref)
        % Record some quantity by providing a NrnRef to that quantity.
        %   record(nrnref)
            clib.neuron.record(self.vec, nrnref);
        end

        function value = call_method_hoc(self, method, returntype, varargin)
        % Call method by passing method name (method) to HOC lookup, along with its return type (returntype) and method arguments (varargin).
        %   value = call_method_double(method, varargin)
            
            try
                sym = clib.neuron.get_method_sym(self.vec, method);
                n = length(varargin);
                for i=1:n
                    arg = varargin{i};
                    if (isa(arg, "double"))
                        clib.neuron.matlab_hoc_pushx(arg);  
                    elseif (isa(arg, "string") || isa(arg, "char"))
                        clib.neuron.matlab_hoc_pushstr(arg);  
                    elseif (isa(arg, "Vector"))
                        clib.neuron.matlab_hoc_pushobj(arg);  
                    elseif (isa(arg, "NrnRef"))
                        clib.neuron.matlab_hoc_pushpx(arg);  
                    else
                        error("Input of type "+class(arg)+" not allowed.");
                    end
                end
                clib.neuron.matlab_hoc_call_ob_proc(self.vec, sym, n);
                if (returntype=="double")
                    value = clib.neuron.matlab_hoc_xpop();
                elseif (returntype=="string")
                    value = clib.neuron.matlab_hoc_strpop();
                elseif (returntype=="object")
                    nrnvec = clib.neuron.matlab_hoc_objpop();
                    value = neuron.Vector(0, nrnvec);
                elseif (returntype=="void")
                    value = self;
                end
            % TODO: if the above code fails, Matlab often just crashes instead of catching an error.
            catch  
                warning("'"+string(method)+"': number or type of arguments incorrect.")
            end

        end

        function list_methods(self)
        % List all available methods to be called using HOC lookup.
        %   list_methods()
            disp("For now, only methods with type 270 or 329 can be called.");
            for i=1:length(self.method_list)
                mth = self.method_list(i).split(":");
                disp("Name: " + mth(1) + ", type: " + mth(2));
            end
        end

        function varargout = subsref(self, S)
        % If a method is called, but it is not listed above, try to run it by calling self.hoc_get().
        %   Available methods are displayed using Vector.list_methods().
        %   Method documentation can be found at https://nrn.readthedocs.io/en/latest/python/programming/math/vector.html.
        %
        %   Direct Vector data element access is possible using:
        %   vec(1), vec(1:5), vec{1}

            % S(1).subs is method name;
            % S(2).subs is a cell array containing arguments.
            method = S(1).subs;

            % Are we trying to directly access Vector data elements?
            if (length(S) == 1)
                arr = self.double();
                [varargout{1:nargout}] = arr(S(1).subs{:});
            % Is the provided method listed above?
            elseif any(strcmp(methods(self), method))
                [varargout{1:nargout}] = builtin('subsref', self, S);
            % Special case: size
            % If we make an array of Vectors, and ask for its size, Matlab
            % throws an error if we don't exclude this special case here.
            elseif (method == "size")
                % Do nothing.
            % Is this method present in the HOC lookup table, and does it return a double?
            elseif any(strcmp(self.method_list, method+":270"))
                [varargout{1:nargout}] = call_method_hoc(self, method, "double", S(2).subs{:});
            % Is this method present in the HOC lookup table, and does it return a void?
            elseif any(strcmp(self.method_list, method+":329"))
                [varargout{1:nargout}] = call_method_hoc(self, method, "void", S(2).subs{:});
            % Is this method present in the HOC lookup table, and does it return a string?
            elseif any(strcmp(self.method_list, method+":330"))
                [varargout{1:nargout}] = call_method_hoc(self, method, "string", S(2).subs{:});
            else
                warning("'"+string(method)+"': not found; call Vector.list_methods() to see all available methods.")
            end
        end

    end
end