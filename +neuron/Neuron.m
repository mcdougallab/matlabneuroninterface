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

            % Add dynamic properties.
            % TODO: Setting crashes for n.L (and perhaps for other variables as well).
            % Hence, we cannot neatly set all properties upon initialization like we do for neuron.Object.
            for i=1:length(self.function_list)
                func = split(self.function_list(i), ":");
                if (func(2) == "263")
                    p = self.addprop(func(1));
                    p.SetMethod = self.set_prop(func(1));
                end
            end
        end
        function varargout = subsref(self, S)
        % If a function is called, but it is not listed as a Neuron class method, try to run it by calling self.call_func_hoc().
        %   Available functions are displayed using Neuron.list_function().
        %
        %   Getting/setting direct top-level variable access is possible using:
        %   n = neuron.Neuron();
        %   n.t, n.dt, n.GAMMA, n.PHI, etc.

            % S(1).subs is function name;
            % S(2).subs is a cell array containing arguments.
            func = S(1).subs;

            % Are we trying to directly access a top-level variable?
            if (isa(func, "char") && length(S) == 1 && any(strcmp(self.function_list, func+":263")))
                [varargout{1:nargout}] = clib.neuron.ref(func).get();
            % Check for special type "Section";
            % the special type "Vector" is checked in self.hoc_new_obj().
            elseif (func == "Section")
                name = S(2).subs{1};
                [varargout{1:nargout}] = neuron.Section(name);
            % Is the provided function listed as a Neuron class method?
            elseif any(strcmp(methods(self), func))
                [varargout{1:nargout}] = builtin('subsref', self, S);
            % Is this method present in the HOC lookup table, and does it return a double?
            elseif any(strcmp(self.function_list, func+":280"))
                [varargout{1:nargout}] = self.call_func_hoc(func, "double", S(2).subs{:});
            % Is this method present in the HOC lookup table, and does it return an Object?
            elseif any(strcmp(self.function_list, func+":325"))
                [varargout{1:nargout}] = self.hoc_new_obj(func, S(2).subs{:});
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

        function p = set_prop(self, propname)
        % Set dynamic property.
        %   set_prop(obj, propname)
            function set_nrn_property(~, value)
                clib.neuron.ref(propname).set(value);
                self.(propname) = value;
            end
            p = @set_nrn_property;
        end

    end
    methods(Static)
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