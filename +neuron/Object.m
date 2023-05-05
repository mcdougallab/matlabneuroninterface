classdef Object < dynamicprops
% Neuron Object Class

    properties (SetAccess=protected, GetAccess=public)
        obj             % C++ Neuron Object.
        objtype         % Neuron Object type
        attr_list       % List of attributes of the C++ object.
        attr_array_map  % Map of array attributes of the C++ object.
                        % Keys are property names, values are array lengths.
        mt_double_list  % List of methods of the C++ object, returning a double.
        mt_object_list  % List of methods of the C++ object, returning an object.
        mt_string_list  % List of methods of the C++ object, returning a string.
    end
    
    methods

        function self = Object(obj)
        % Initialize Object
        %   Object(obj) constructs a Matlab wrapper for Neuron Object obj

            self = self@dynamicprops;
            self.attr_array_map = containers.Map;
            if clib.neuron.isinitialized()
                self.objtype = obj.ctemplate.sym.name;
                self.obj = obj;

                % Get method list.
                method_str = clib.neuron.get_class_methods(self.objtype);
                method_list = split(method_str, ";");
                method_list = method_list(1:end-1);

                % Add dynamic properties.
                % See: doc/DEV_README.md#neuron-types
                for i=1:length(method_list)
                    method = split(method_list(i), ":");
                    method_types = split(method(2), "-");
                    method_type = method_types(1);
                    % method_subtype = method_types(2);
                    if (method_type == "263" && method(1) ~= 'x')  % steered property; we need to exclude Vector.x and Matrix.x to prevent errors.
                        self.attr_list = [self.attr_list method(1)];
                        p = self.addprop(method(1));
                        p.GetMethod = @(self)get_steered_prop(self, method(1));
                        p.SetMethod = @(self, value)set_steered_prop(self, method(1), value);
                    elseif (method_type == "310")  % point process property
                        sym = clib.neuron.hoc_table_lookup(method(1), self.obj.ctemplate.symtable);
                        if clibIsNull(sym.arayinfo)  % scalar property
                            self.attr_list = [self.attr_list method(1)];
                            p = self.addprop(method(1));
                            p.GetMethod = @(self)get_pp_prop(self, method(1));
                            p.SetMethod = @(self, value)set_pp_prop(self, method(1), value);
                        else  % array property
                            n = sym.arayinfo.sub.double();
                            self.attr_array_map(method(1)) = n;
                            p = self.addprop(method(1));
                            p.GetMethod = @(self)get_pp_arr(self, method(1));
                            p.SetMethod = @(self, value)set_pp_arr(self, method(1), value);
                        end
                    elseif (method_type == "270")
                        self.mt_double_list = [self.mt_double_list method(1)];
                    elseif (method_type == "328")
                        self.mt_object_list = [self.mt_object_list method(1)];
                    elseif (method_type == "329")
                        self.mt_string_list = [self.mt_string_list method(1)];
                    end
                end
            else
                warning("Initialize a Neuron session before making an Object.");
            end
        end

        function delete(self)
        % Decrease refcount by 1; if refcount is 0, release the C++ Object.
        %   delete()

            clib.neuron.hoc_obj_unref(self.obj);

            % We need to do this, or else we get crashes.
            if self.obj.refcount == 0
                clibRelease(self.obj);
            end

        end

        function obj = get_obj(self)
        % Access C++ Object.
        %   obj = get_obj()
            obj = self.obj;
        end

        function value = call_method_hoc(self, method, returntype, varargin)
        % Call method by passing method name (method) to HOC lookup, along with its return type (returntype) and method arguments (varargin).
        %   value = call_method_double(method, varargin)
            
            % Save state & try/catch in case the call fails.
            clib.neuron.increase_try_catch_nest_depth();
            state = clib.neuron.SavedState();
            try
                [nsecs, nargs] = neuron.stack.push_args(varargin{:});
                sym = clib.neuron.hoc_table_lookup(method, ...
                    self.obj.ctemplate.symtable);
                clib.neuron.hoc_call_ob_proc(self.obj, sym, nargs);
                value = neuron.stack.hoc_pop(returntype);
                neuron.stack.pop_sections(nsecs);
            catch e
                warning(e.message);
                warning("'"+string(method)+"': number or type of arguments incorrect.");
                value = NaN;
                state.restore();
            end
            clibRelease(state);
            clib.neuron.decrease_try_catch_nest_depth();

        end

        function list_methods(self)
        % List all available methods to be called using HOC lookup.
        %   list_methods()
            if ~isempty(self.attr_list)
                disp("Available attributes:")
                for i=1:length(self.attr_list)
                    disp("    "+self.attr_list(i));
                end
            end
            if ~isempty(self.mt_double_list)
                disp("Available methods (returning a double):")
                for i=1:length(self.mt_double_list)
                    disp("    "+self.mt_double_list(i));
                end
            end
            if ~isempty(self.mt_object_list)
                disp("Available methods (returning an object):")
                for i=1:length(self.mt_object_list)
                    disp("    "+self.mt_object_list(i));
                end
            end
            if ~isempty(self.mt_string_list)
                disp("Available methods (returning a string):")
                for i=1:length(self.mt_string_list)
                    disp("    "+self.mt_string_list(i));
                end
            end
        end

        function self = subsasgn(self, S, varargin)
        % Assign a (dynamic) property value.
            % Are we trying to directly assign a class property?
            if (isa(S(1).subs, "char") && length(S) == 1 && isprop(self, S(1).subs))
                self.(S(1).subs) = varargin{:};
            % Are we trying to directly assign a class property array?
            elseif (isa(S(1).subs, "char") && length(S) == 2 && isprop(self, S(1).subs))
                self.set_pp_arr_element(S(1).subs, varargin{:}, S(2).subs{:});
            end
        end

        function varargout = subsref(self, S)
        % If a method is called, but it is not listed above, try to run it by calling self.call_method_hoc().

            % S(1).subs is method name;
            % S(2).subs is a cell array containing arguments.
            method = S(1).subs;

            % Is the provided method listed above?
            if ismethod(self, method)
                [varargout{1:nargout}] = builtin('subsref', self, S);
            % Are we trying to directly access a class property?
            elseif (isa(method, "char") && length(S) == 1 && isprop(self, method))
                [varargout{1:nargout}] = self.(method);
            % Are we trying to directly access a class property array?
            elseif (isa(method, "char") && length(S) == 2 && isprop(self, method))
                [varargout{1:nargout}] = self.(method)(S(2).subs{:});
            % Is this method present in the HOC lookup table, and does it return a double?
            elseif any(strcmp(self.mt_double_list, method))
                [varargout{1:nargout}] = call_method_hoc(self, method, "double", S(2).subs{:});
            % Is this method present in the HOC lookup table, and does it return an object?
            elseif any(strcmp(self.mt_object_list, method))
                [varargout{1:nargout}] = call_method_hoc(self, method, "Object", S(2).subs{:});  
            % Is this method present in the HOC lookup table, and does it return a string?
            elseif any(strcmp(self.mt_string_list, method))
                [varargout{1:nargout}] = call_method_hoc(self, method, "string", S(2).subs{:});
            else
                warning("'"+string(method)+"': not found; call Object.list_methods() to see all available methods.")
            end
        end

        function set_pp_prop(self, propname, value)
        % Set dynamic property.
        %   set_pp_prop(propname, value)
            clib.neuron.set_pp_property(self.obj, propname, value);
        end

        function value = get_pp_prop(self, propname)
        % Get dynamic property.
        %   value = get_pp_prop(propname)
            value = clib.neuron.get_pp_property(self.obj, propname);
        end

        function value = get_pp_arr(self, propname)
        % Get dynamic property array.
        %   value = get_pp_arr(propname)
            n = self.attr_array_map(propname);
            value = zeros(1, n);
            for i=1:n
                value(i) = clib.neuron.get_pp_property(self.obj, propname, i-1);
            end
        end

        function set_pp_arr(self, propname, value)
        % Set dynamic property array.
        %   set_pp_arr(propname, value)
            n = self.attr_array_map(propname);
            assert(length(value) == n);
            for i=1:n
                self.set_pp_arr_element(propname, value(i), i);
            end
        end

        function set_pp_arr_element(self, propname, value, i)
        % Set dynamic property array element.
        %   set_pp_arr_element(propname, value, index)
            clib.neuron.set_pp_property(self.obj, propname, value, i-1);
        end

        function set_steered_prop(self, propname, value)
        % Set dynamic property.
        %   set_prop(propname, value)
            clib.neuron.set_steered_property(self.obj, propname, value);
        end

        function value = get_steered_prop(self, propname)
        % Get dynamic property.
        %   value = get_prop(propname)
            value = clib.neuron.get_steered_property(self.obj, propname);
        end

        function nrnref = ref(self, propname, index)
        % Get reference to property or property array element.
        %   nrnref = ref(prop_name)
        %   nrnref = ref(prop_arr_name, index)
            if ~exist('index', 'var')
                nrnref = clib.neuron.ref_pp_property(self.obj, propname);
            else
                nrnref = clib.neuron.ref_pp_property(self.obj, propname, index-1);
            end
        end
    end
end