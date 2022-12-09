classdef Neuron < dynamicprops
% Neuron Class for initializing a Neuron session and running generic Neuron functions.

    properties (SetAccess=protected, GetAccess=public)
        var_list        % List of top-level Neuron variables.
        fn_double_list  % List of top-level Neuron functions returning a double.
        fn_string_list  % List of top-level Neuron functions returning a string.
        object_list     % List of Neuron Objects.
    end

    methods
        function self = Neuron()
        % Initialize the neuron session, if it has not been initialized before.
        %   Neuron()
            self = self@dynamicprops;
            clib.neuron.initialize();
            arr = split(clib.neuron.get_nrn_functions(), ";");
            call_list = arr(1:end-1);

            % Add dynamic properties.
            % See: doc/DEV_README.md#neuron-types
            % TODO: 
            % - Setting the property crashes for n.L (and perhaps for other variables as well).
            % - p.GetMethod also crashes for the same variables
            % - Hence, we cannot neatly get/set all properties upon initialization like we do for neuron.Object.
            for i=1:length(call_list)
                f = split(call_list(i), ":");
                if (f(2) == "263") % variable
                    self.var_list = [self.var_list f(1)];
                    p = self.addprop(f(1));
                    p.SetMethod = @(value)set_prop(f(1), value);
                elseif (f(2) == "280") % function returning a double
                    self.fn_double_list = [self.fn_double_list f(1)];
                elseif (f(2) == "296") % function returning a string
                    self.fn_string_list = [self.fn_string_list f(1)];
                elseif (f(2) == "325") % object
                    self.object_list = [self.object_list f(1)];
                end
            end
        end
        function varargout = subsref(self, S)
        % If a function is called, but it is not listed as a Neuron class method, try to run it by calling self.call_func_hoc().
        %   Available functions are displayed using Neuron.list_function().
        %
        %   Getting/setting direct top-level variables is possible using:
        %   n = neuron.Neuron();
        %   n.t, n.dt, n.GAMMA, n.PHI, etc.

            % S(1).subs is function name;
            % S(2).subs is a cell array containing arguments.
            func = S(1).subs;

            % Are we trying to directly access a top-level variable?
            if (isa(func, "char") && length(S) == 1 && any(strcmp(self.var_list, func)))
                [varargout{1:nargout}] = clib.neuron.ref(func).get();
            % Are we trying to directly access a Matlab defined property?
            elseif (isa(func, "char") && length(S) == 1 && isprop(self, func))
                [varargout{1:nargout}] = self.(func);
            % Check for special type "Section";
            % the special type "Vector" is checked in self.hoc_new_obj().
            elseif (func == "Section")
                name = S(2).subs{1};
                [varargout{1:nargout}] = neuron.Section(name);
            % Is the provided function listed as a Neuron class method?
            elseif any(strcmp(methods(self), func))
                [varargout{1:nargout}] = builtin('subsref', self, S);
            % Is this method present in the HOC lookup table, and does it return a double?
            elseif any(strcmp(self.fn_double_list, func))
                [varargout{1:nargout}] = self.call_func_hoc(func, "double", S(2).subs{:});
            % Is this method present in the HOC lookup table, and does it return an Object?
            elseif any(strcmp(self.object_list, func))
                [varargout{1:nargout}] = self.hoc_new_obj(func, S(2).subs{:});
            % Is this method present in the HOC lookup table, and does it return a string?
            elseif any(strcmp(self.fn_string_list, func))
                [varargout{1:nargout}] = self.call_func_hoc(func, "string", S(2).subs{:});
            else
                warning("'"+string(func)+"': not found; call Neuron.list_functions() to see all available methods and attributes.")
            end
        end
        function list_functions(self)
        % List all available top-level functions from Neuron.
        %   list_functions()
            disp("Available variables:")
            for i=1:self.var_list.length()
                disp("    "+self.var_list(i));
            end
            disp("Available functions (returning a double):")
            for i=1:self.fn_double_list.length()
                disp("    "+self.fn_double_list(i));
            end
            disp("Available functions (returning a string):")
            for i=1:self.fn_string_list.length()
                disp("    "+self.fn_string_list(i));
            end
            disp("Available objects:")
            for i=1:self.object_list.length()
                disp("    "+self.object_list(i));
            end
        end

    end
    methods(Static)
        function set_prop(propname, value)
        % Set dynamic property.
        %   set_prop(propname, value)
            clib.neuron.ref(propname).set(value);
        end
        function value = call_func_hoc(func, returntype, varargin)
        % Call function by passing function name (func) to HOC lookup, along with its return type (returntype) and arguments (varargin).
        %   value = call_func_hoc(func, returntype, varargin)

            try
                n = length(varargin);
                for i=1:n
                    neuron.hoc_push(varargin{i});
                end
                sym = clib.neuron.hoc_lookup(func);
                func_val = clib.neuron.hoc_call_func(sym, n);
                if (returntype=="double")
                    value = func_val;
                else
                    value = neuron.hoc_pop(returntype);
                end
            % TODO: if the above code fails, Matlab often just crashes instead of catching an error.
            catch  
                warning("'"+string(func)+"': number or type of arguments incorrect.");
            end

        end
        function obj = hoc_new_obj(objtype, varargin)
        % Make object by providing object type (objtype) and constructor arguments (varargin).
        %   obj = hoc_new_obj(objtype, varargin)

            try
                nargs = length(varargin);
                nsecs = 0;
                for i=1:length(varargin)
                    arg = varargin{i};
                    if (isa(arg, "neuron.Section"))
                        nargs = nargs - 1;
                        nsecs = nsecs + 1;
                        clib.neuron.nrn_pushsec(arg.get_sec());
                    else
                        neuron.hoc_push(arg);
                    end
                end
                sym = clib.neuron.hoc_lookup(objtype);
                cppobj = clib.neuron.hoc_newobj1(sym, nargs);
                if (objtype == "Vector")
                    obj = neuron.Vector(cppobj);
                else
                    obj = neuron.Object(objtype, cppobj);
                end
                for i=1:nsecs
                    clib.neuron.nrn_sec_pop();
                end
            catch  
                warning("'"+string(objtype)+"': number or type of arguments incorrect.");
            end

        end
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
        function reset_sections()
        % Reset topology.
        %   reset_sections()
            clib.neuron.hoc_oc("forall delete_section()");
        end
    end
end