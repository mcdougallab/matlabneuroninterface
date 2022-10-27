classdef Neuron < dynamicprops
% Neuron Class for initializing a Neuron session and running generic Neuron functions.

    properties (Access=private)
        function_list       % List of top-level functions.
    end

    methods
        function self = Neuron()
        % Initialize the neuron session, if it has not been initialized before.
        %   Neuron()
            self = self@dynamicprops;
            clib.neuron.initialize();
            arr = split(clib.neuron.get_nrn_functions(), ";");
            self.function_list = arr(1:end-1);
        end
        function value = call_func_hoc(self, func, returntype, varargin)
        % Call function by passing function name (func) to HOC lookup, along with its return type (returntype) and arguments (varargin).
        %   value = call_method_double(method, varargin)
            
            try
                n = length(varargin);
                for i=1:n
                    arg = varargin{i};
                    if (isa(arg, "double"))
                        clib.neuron.hoc_pushx(arg);  
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
                % TODO: remove
                % func_val = clib.neuron.matlab_hoc_call_func(func, n);
                sym = clib.neuron.hoc_lookup(func);
                func_val = clib.neuron.hoc_call_func(sym, n);
                if (returntype=="double")
                    value = func_val;
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
                warning("'"+string(func)+"': number or type of arguments incorrect.")
            end

        end
        function varargout = subsref(self, S)
        % If a function is called, but it is not listed as a Neuron class method, try to run it by calling self.call_func_hoc().
        %   Available functions are displayed using Neuron.list_function().
        %
        %   Getting (NOT setting) direct top-level variable access is possible using:
        %   n = neuron.Neuron();
        %   n.t, n.dt, n.GAMMA, n.PHI, etc.
        %
        %   TODO: Crashes for n.L (and perhaps for other variables as well).

            % S(1).subs is function name;
            % S(2).subs is a cell array containing arguments.
            func = S(1).subs;

            % Are we trying to directly access a top-level variable?
            if (isa(func, "char") && length(S) == 1 && any(strcmp(self.function_list, func+":263")))
                [varargout{1:nargout}] = clib.neuron.ref(func).get();
            % Is the provided function listed as a Neuron class method?
            elseif any(strcmp(methods(self), func))
                [varargout{1:nargout}] = builtin('subsref', self, S);
            % Is this method present in the HOC lookup table, and does it return a double?
            elseif any(strcmp(self.function_list, func+":280"))
                [varargout{1:nargout}] = call_func_hoc(self, func, "double", S(2).subs{:});
            else
                warning("'"+string(func)+"': not found; call Neuron.list_functions() to see all available methods and attributes.")
            end
        end
        function list_functions(self)
        % List all available top-level functions from Neuron.
        %   list_functions()
            warning("For now, only attributes with type 263 (double) or methods with type 280 (double) can be called.");
            for i=1:length(self.function_list)
                fnc = self.function_list(i).split(":");
                disp("Name: " + fnc(1) + ", type: " + fnc(2));
            end
        end

    end
    methods(Static)
        function value = hoc_oc(str)
        % Pass string to hoc_oc.
        %   hoc_oc()
            value = clib.neuron.hoc_oc(str);
        end
        function nrnref = ref(sym)
        % Return an NrnRef containing a pointer to a top-level symbol (sym).
        %   nrnref = ref(sym)
            nrnref = clib.neuron.ref(sym);
        end
    end
end