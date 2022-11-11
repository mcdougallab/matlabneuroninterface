classdef Object < dynamicprops
% Neuron Object Class

    properties (SetAccess=protected, GetAccess=public)
        objtype         % Neuron Object type
        obj             % C++ Neuron Object.
        attr_list       % List of attributes of the C++ object.
        mt_double_list  % List of methods of the C++ object, returning a double.
        mt_object_list  % List of methods of the C++ object, returning an object.
        mt_string_list  % List of methods of the C++ object, returning a string.
    end
    
    methods

        function self = Object(objtype, obj)
        % Initialize Object
        %   Object(objtype, obj) constructs a Matlab wrapper for Neuron 
        %   Object obj of type objtype

            self = self@dynamicprops;
            if clib.neuron.isinitialized()
                self.objtype = objtype;
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
                    if (method_type == "311")
                        self.attr_list = [self.attr_list method(1)];
                        p = self.addprop(method(1));
                        p.GetMethod = @(self)get_prop(self, method(1));
                        p.SetMethod = @(self, value)set_prop(self, method(1), value);
                    elseif (method_type == "270")
                        self.mt_double_list = [self.mt_double_list method(1)];
                    elseif (method_type == "329")
                        self.mt_object_list = [self.mt_object_list method(1)];
                    elseif (method_type == "330")
                        self.mt_string_list = [self.mt_string_list method(1)];
                    end
                end
            else
                warning("Initialize a Neuron session before making an Object.");
            end
        end

        function delete(self)
        % Destroy the Object.
        %   delete()

            % Release self.obj C++ object.
            if (class(self.obj) == "clib.neuron.Object")
                clib.neuron.hoc_obj_unref(self.obj);
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
            
            % TESTING nrn_try_catch_nest_depth.
            clib.neuron.increase_try_catch_nest_depth();

            try
                n = length(varargin);
                for i=1:n
                    neuron.hoc_push(varargin{i});
                end
                sym = clib.neuron.hoc_table_lookup(method, ...
                    self.obj.ctemplate.symtable);
                clib.neuron.hoc_call_ob_proc(self.obj, sym, n);
                value = neuron.hoc_pop(returntype);
            % TODO: if the above code fails, the first time an error is
            % caught, but the second time the program just crashes (see 
            % examples/example_crash.m).
            catch  
                warning("'"+string(method)+"': number or type of arguments incorrect.");
            end

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
            % Special case: size
            % If we make an array of Objects, and ask for its size, Matlab
            % throws an error if we don't exclude this special case here.
            % TODO: check behavior for Objects other than Vector.
            elseif (method == "size")
                % Do nothing; method is replaced by self.length().
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

        function set_prop(self, propname, value)
        % Set dynamic property.
        %   set_prop(propname)
            clib.neuron.set_pp_property(self.obj, propname, value);
        end

        function value = get_prop(self, propname)
        % Get dynamic property.
        %   value = get_prop(propname)
            value = clib.neuron.get_pp_property(self.obj, propname);
        end
    end
end