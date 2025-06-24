classdef Object < dynamicprops
% NEURON Object Class

    properties (SetAccess=protected, GetAccess=public)
        idx             % Unique index for this Object instance.
        obj             % C++ NEURON Object.
        objtype         % NEURON Object type
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
        %   Object(obj) constructs a Matlab wrapper for NEURON Object obj

            self = self@dynamicprops;
            self.attr_array_map = containers.Map;
            self.objtype = neuron_api('nrn_class_name', obj);
            self.obj = obj;
            index = neuron.Session.call_func_hoc('object_id', 'double', self, 1);
            self.idx = index;

            % Get method list.
            method_str = neuron_api('get_class_methods', self.objtype);
            method_list = split(method_str, ";");
            method_list = method_list(1:end-1);
            % disp(method_list);

            % Add dynamic properties.
            % See: doc/DEV_README.md#neuron-types
            for i=1:length(method_list)
                method = split(method_list(i), ":");
                method_types = split(method(2), "-");
                method_type = method_types(1);
                % method_subtype = method_types(2);
                if (method_type == "263" && method{1}(1) ~= 'x')  % steered property; we need to exclude Vector.x and Matrix.x to prevent errors.
                    self.attr_list = [self.attr_list method(1)];
                    p = self.addprop(method{1});
                    p.GetMethod = @(self)get_steered_prop(self, method{1});
                    p.SetMethod = @(self, value)set_steered_prop(self, method{1}, value);
                elseif (method_type == "310")  % point process property
                    sym = neuron_api('nrn_method_symbol', self.obj, method{1});
                    if ~neuron_api('nrn_symbol_is_array', sym) % scalar property
                        self.attr_list = [self.attr_list method(1)];
                        p = self.addprop(method{1});
                        p.GetMethod = @(self)get_pp_prop(self, method{1});
                        p.SetMethod = @(self, value)set_pp_prop(self, method{1}, value);
                    else  % array property
                        % n = sym.arayinfo.sub.double();
                        n = (neuron_api('nrn_symbol_array_length', sym));
                        self.attr_array_map(method{1}) = n;
                        p = self.addprop(method{1});
                        p.GetMethod = @(self)get_pp_arr(self, method{1});
                        p.SetMethod = @(self, value)set_pp_arr(self, method{1}, value);
                    end
                elseif (method_type == "270")
                    self.mt_double_list = [self.mt_double_list method(1)];
                elseif (method_type == "329")
                    self.mt_object_list = [self.mt_object_list method(1)];
                elseif (method_type == "330")
                    self.mt_string_list = [self.mt_string_list method(1)];
                end
            end
        end

        function delete(self)
        % Decrease refcount by 1.
        %   delete()
            neuron_api('nrn_object_unref', self.obj);

        end

        function obj = get_obj(self)
        % Access C++ Object.
        %   obj = get_obj()
            obj = self.obj;
        end

        function value = call_method_hoc(self, method, returntype, varargin)
        % Call method by passing method name (method) to HOC lookup, along with its return type (returntype) and method arguments (varargin).
        %   value = call_method_double(method, varargin)
            try
                if self.objtype == "Matrix"
                    if method == "getval" || ...
                       method == "setval"
                        if nargin >= 2
                            for i = 1:2
                                if isnumeric(varargin{i}) 
                                    varargin{i} = varargin{i} - 1;
                                end
                            end
                        end
                    end
                    if method == "sprowlen" || ...
                       method == "getrow" || ...
                       method == "getcol" || ...
                       method == "getdiag" || ...
                       method == "setrow" || ...
                       method == "setcol" || ...
                       method == "setdiag"
                        if nargin >= 1
                            if isnumeric(varargin{1}) 
                                varargin{1} = varargin{1} - 1;
                            end
                        end
                    end
                    if method == "spgetrowval"
                        if nargin >= 2
                            % Adjust i and jx to 0-based for NEURON
                            for k = 1:2
                                if isnumeric(varargin{k})
                                    varargin{k} = varargin{k} - 1;
                                end
                            end
                        end
                    end
                    if method == "bcopy"
                        if nargin >= 2
                            for i = 1:2
                                if isnumeric(varargin{i}) 
                                    varargin{i} = varargin{i} - 1;
                                end
                            end
                        end
                        if nargin >= 6
                            for i = 5:6
                                if isnumeric(varargin{i}) 
                                    varargin{i} = varargin{i} - 1;
                                end
                            end
                        end
                    end
                end
                [nsecs, nargs] = neuron.stack.push_args(varargin{:});
                sym = neuron_api('nrn_method_symbol', self.obj, method);
                neuron_api('nrn_method_call', self.obj, sym, nargs);
                value = neuron.stack.hoc_pop(returntype);
                neuron.stack.pop_sections(nsecs);
                if method == "spgetrowval"
                    if (nargin >= 3 && isa(varargin{3}, 'neuron.NrnRef'))
                        neuron_api('nrnref_vector_set', varargin{3}.obj, varargin{3}(1) + 1, 0);
                    end
                end
            catch e
                warning(e.message);
                warning("'"+string(method)+"': caught error during call to NEURON function.");
                value = NaN;
                % state.restore();
            end

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
            % Assign a (dynamic) property value.
            % Are we trying to directly assign a class property?
            if (isa(S(1).subs, "char") && length(S) == 1 && isprop(self, S(1).subs))
                if any(strcmp(S(1).subs, {'obj', 'objtype', 'attr_list', 'attr_array_map', ...
                                          'mt_double_list', 'mt_object_list', 'mt_string_list'}))
                    error("Property '%s' is read-only and cannot be set after construction.", S(1).subs);
                end
                self.(S(1).subs) = varargin{:};
            % Are we trying to directly assign a class property array?
            elseif (isa(S(1).subs, "char") && length(S) == 2 && isprop(self, S(1).subs))
                self.set_pp_arr_element(S(1).subs, varargin{:}, S(2).subs{:});
            else
                error("'%s': not found; call Object.list_methods() to see all available methods and attributes.", string(S(1).subs));
            end
        end

        function varargout = subsref(self, S)
        % If a method is called, but it is not listed above, try to run it by calling self.call_method_hoc().

            % S(1).subs is method name;
            % S(2).subs is a cell array containing arguments.
            method = S(1).subs;

            if S(1).type == "."
                if numel(S) > 1
                    n_processed = 2;  % Number of elements of S to process.
                    % Is the provided method listed above?
                    if ismethod(self, method)
                        [varargout{1:nargout}] = builtin('subsref', self, S(1:2));
                    % Are we trying to directly access a class property array element?
                    elseif ((S(2).type == "()") && any(isprop(self, method)))
                        [varargout{1:nargout}] = self.(method)(S(2).subs{:});
                    % Are we trying to directly access a class property in a chained call?
                    elseif isprop(self, method)
                        [varargout{1:nargout}] = self.(method);
                        n_processed = 1;  % Number of elements of S to process.
                    % Is this method present in the HOC lookup table, and does it return a double?
                    elseif any(strcmp(self.mt_double_list, method))
                        [varargout{1:nargout}] = call_method_hoc(self, method, "double", S(2).subs{:});
                    % Is this method present in the HOC lookup table, and does it return an object?
                    elseif any(strcmp(self.mt_object_list, method))
                        [varargout{1:nargout}] = call_method_hoc(self, method, "Object", S(2).subs{:});  
                    % Is this method present in the HOC lookup table, and does it return a string?
                    elseif any(strcmp(self.mt_string_list, method))
                        [varargout{1:nargout}] = call_method_hoc(self, method, "string", S(2).subs{:});
                    % If none of the above, throw error.
                    else
                        error("'"+string(func)+"': not found; call Object.list_methods() " + ...
                              "to see all available methods and attributes.")
                    end
                else
                    % Are we trying to directly access a class property?
                    if isprop(self, method)
                        [varargout{1:nargout}] = self.(method);
                        n_processed = 1;
                    % If none of the above, throw error.
                    else
                        error("'"+string(func)+"': not found; call Object.list_methods() " + ...
                              "to see all available methods and attributes.")
                    end
                end
            % Other indexing types ({} or ()) not supported.
            else
                error("Indexing type "+S(1).type+" not supported.");
            end
            [varargout{1:nargout}] = neuron.chained_method(varargout, S, n_processed);
        end

        function set_pp_prop(self, propname, value)
        % Set dynamic property.
        %   set_pp_prop(propname, value)
            if ~(neuron_api('nrn_prop_exists', self.obj))
                error("The property '%s' does not exist", propname);
            end
            neuron_api('nrn_property_set', self.obj, propname, value);
        end

        function value = get_pp_prop(self, propname)
        % Get dynamic property.
        %   value = get_pp_prop(propname)
            if ~(neuron_api('nrn_prop_exists', self.obj))
                error("The property '%s' does not exist", propname);
            end
            value = neuron_api('nrn_property_get', self.obj, propname); % THIS IS WHERE IT ERRORS
        end

        function value = get_pp_arr(self, propname)
        % Get dynamic property array.
        %   value = get_pp_arr(propname)
            if ~(neuron_api('nrn_prop_exists', self.obj))
                error("The property '%s' does not exist", propname);
            end
            n = self.attr_array_map(propname);
            value = zeros(1, n);
            for i=1:n
                value(i) = neuron_api('nrn_property_array_get', self.obj, propname, i-1);
            end
        end

        function set_pp_arr(self, propname, value)
        % Set dynamic property array.
        %   set_pp_arr(propname, value)
            if ~(neuron_api('nrn_prop_exists', self.obj))
                error("The property '%s' does not exist", propname);
            end
            n = self.attr_array_map(propname);
            assert(length(value) == n);
            for i=1:n
                self.set_pp_arr_element(propname, value(i), i);
            end
        end

        function set_pp_arr_element(self, propname, value, i)
        % Set dynamic property array element.
        %   set_pp_arr_element(propname, value, index)
            if ~(neuron_api('nrn_prop_exists', self.obj))
                error("The property '%s' does not exist", propname);
            end
            neuron_api('nrn_property_array_set', self.obj, propname, value, i-1);
        end

        function set_steered_prop(self, propname, value)
        % Set dynamic property.
        %   set_prop(propname, value)
            if ~(neuron_api('nrn_prop_exists', self.obj))
                error("The property '%s' does not exist", propname);
            end
            neuron_api('nrn_property_set', self.obj, propname, value);
        end

        function value = get_steered_prop(self, propname)
        % Get dynamic property.
        %   value = get_prop(propname)
            if ~(neuron_api('nrn_prop_exists', self.obj))
                error("The property '%s' does not exist", propname);
            end
            value = neuron_api('nrn_property_get', self.obj, propname);
        end

        function nrnref = ref(self, propname, index)
        % Get reference to property or property array element.
        %   nrnref = ref(prop_name)
        %   nrnref = ref(prop_arr_name, index)
            if ~exist('index', 'var')
                nrnref = neuron.NrnRef(neuron_api('nrn_pp_property_nrnref', self.obj, propname));
            else
                nrnref = neuron.NrnRef(neuron_api('nrn_pp_property_array_nrnref', self.obj, propname, index-1));
            end
        end
    end
end