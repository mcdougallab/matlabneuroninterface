classdef Session < dynamicprops
% Neuron Class for initializing a Neuron session and running generic Neuron functions.

    properties (SetAccess=protected, GetAccess=public)
        var_list        % List of top-level Neuron variables.
        fn_double_list  % List of top-level Neuron functions returning a double.
        fn_string_list  % List of top-level Neuron functions returning a string.
        fn_void_list    % List of top-level Neuron functions returning nothing.
        object_list     % List of Neuron Objects.
        null            % clib.type.nullptr
    end

    methods
        function self = Session()
        % Initialize the neuron session, if it has not been initialized before.
        %   Session()
            self = self@dynamicprops;
            clib.neuron.initialize();
            self.fill_dynamic_props();
            self.null = clib.type.nullptr;
        end
        function fill_dynamic_props(self)
        % Fill var_list, fn_double_list, fn_string_list, object_list with dynamic variables, functions and objects.
        %   fill_dynamic_props()
            arr = split(clib.neuron.get_nrn_functions(), ";");
            call_list = arr(1:end-1);

            % Reset dynamic method lists.
            self.fn_double_list = string.empty;
            self.fn_void_list = string.empty;
            self.fn_string_list = string.empty;
            self.object_list = string.empty;

            % Add dynamic properties.
            % See: doc/DEV_README.md#neuron-types
            for i=1:length(call_list)
                f = split(call_list(i), ":");
                f_types = split(f(2), "-");
                f_type = f_types(1);
                f_subtype = f_types(2);
                % Depending on the NEURON type (f_type, f_subtype), we add
                % the variable/function as a property (by adding it with 
                % self.addprop) or as a method (by adding it to one of the 
                % various self.*_list arrays).
                switch f_type
                    case "263"  % Properties with get/set functionality.
                        if f(1) == "secondorder" % special case secondorder
                            if ~isprop(self, f(1))
                                self.var_list = [self.var_list f(1)];
                                p = self.addprop(f(1));
                                p.GetMethod = @(self)get_secondorder(self);
                                p.SetMethod = @(self, value)set_secondorder(self, value);
                            end
                        elseif f_subtype == "1" % int variable
                            if ~isprop(self, f(1))
                                self.var_list = [self.var_list f(1)];
                                p = self.addprop(f(1));
                                p.GetMethod = @(self)get_prop(self, f(1));
                                p.SetMethod = @(self, value)set_prop(self, f(1), value);
                            end
                        elseif f_subtype == "2" % double variable
                            if ~isprop(self, f(1))
                                self.var_list = [self.var_list f(1)];
                                p = self.addprop(f(1));
                                p.GetMethod = @(self)get_prop(self, f(1));
                                p.SetMethod = @(self, value)set_prop(self, f(1), value);
                            end
                        end
                    case "270" % HOC function returning a double
                        self.fn_double_list = [self.fn_double_list f(1)];
                    case "271" % HOC procedures (returning nothing)
                        self.fn_void_list = [self.fn_void_list f(1)];
                    case "280" % function returning a double
                        self.fn_double_list = [self.fn_double_list f(1)];
                    case "296" % function returning a string
                        self.fn_string_list = [self.fn_string_list f(1)];
                    case "324" % object
                        self.object_list = [self.object_list f(1)];
                    otherwise
                        % We ignore all other types; they will either be
                        % implemented at a later point, or they are internal 
                        % NEURON types that we do not need to interface with.
                end
            end
        end

        function varargout = dynamic_call(self, S)
        % Implementation of dynamic top-level variable and function calls.

            % S(1).subs is function name;
            % S(2).subs is a cell array containing arguments.
            func = S(1).subs;

            n_processed = 2;  % Number of elements of S to process.
            if S(1).type == "."
                if numel(S) > 1
                    % Are we trying to directly access a Matlab defined property?
                    if isprop(self, func)
                        [varargout{1:nargout}] = self.(func);
                        n_processed = 1;
                    % Check for special type "Section";
                    % the special types "Vector" and "PlotShape" are checked in self.hoc_new_obj().
                    elseif (func == "Section")
                        name = S(2).subs{1};
                        [varargout{1:nargout}] = neuron.Section(name);
                    % Is the provided function listed as a Neuron class method?
                    elseif ismethod(self, func)
                        [varargout{1:nargout}] = builtin('subsref', self, S(1:2));
                    % Is this method present in the HOC lookup table, and does it return nothing?
                    elseif any(strcmp(self.fn_void_list, func))
                        [varargout{1:nargout}] = self.call_func_hoc(func, "void", S(2).subs{:});
                    % Is this method present in the HOC lookup table, and does it return a double?
                    elseif any(strcmp(self.fn_double_list, func))
                        [varargout{1:nargout}] = self.call_func_hoc(func, "double", S(2).subs{:});
                    % Is this method present in the HOC lookup table, and does it return an Object?
                    elseif any(strcmp(self.object_list, func))
                        [varargout{1:nargout}] = self.hoc_new_obj(func, S(2).subs{:});
                    % Is this method present in the HOC lookup table, and does it return a string?
                    elseif any(strcmp(self.fn_string_list, func))
                        [varargout{1:nargout}] = self.call_func_hoc(func, "string", S(2).subs{:});
                    % If none of the above, throw error.
                    else
                        error("'"+string(func)+"': not found; call Neuron.list_functions() " + ...
                              "to see all available methods and attributes.")
                    end
                else
                    % Are we trying to directly access a Matlab defined property?
                    if isprop(self, func)
                        [varargout{1:nargout}] = self.(func);
                        n_processed = 1;
                    % If none of the above, throw error.
                    else
                        error("'"+string(func)+"': not found; call Neuron.list_functions() " + ...
                              "to see all available methods and attributes.")
                    end
                end
            end
            if numel(S) > n_processed
                % Deal with a method/attribute call chain.
                [varargout{1:nargout}] = varargout{:}.subsref(S(n_processed+1:end));
            end

        end

        function varargout = subsref(self, S)
        % Call a top-level variable or function.
        %   Available functions are displayed using Neuron.list_function().
        %
        %   Getting/setting direct top-level variables is possible using:
        %   n = neuron.start_session();
        %   n.t, n.dt, n.GAMMA, n.PHI, etc.
            try
                [varargout{1:nargout}] = self.dynamic_call(S);
            catch  
                % Check again if var/func exists; available functions can
                % change due to importing .hoc files, for example.
                self.fill_dynamic_props();
                [varargout{1:nargout}] = self.dynamic_call(S);
            end
        end
        function list_functions(self)
        % List all available top-level functions from Neuron.
        %   list_functions()
            disp("Available variables:")
            for i=1:self.var_list.length()
                disp("    "+self.var_list(i));
            end
            disp("Available procedures (returning nothing):")
            for i=1:self.fn_void_list.length()
                disp("    "+self.fn_void_list(i));
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
        function value = get_prop(~, propname)
        % Get dynamic property.
        %   get_prop(propname)
            % TODO: this method does not work as GetMethod if we move
            % it to methods(Static)... why?
            value = clib.neuron.ref(propname).get();
        end
        function set_prop(~, propname, value)
        % Set dynamic property.
        %   set_prop(propname, value)
            % TODO: this method does not work as SetMethod if we move
            % it to methods(Static)... why?
            clib.neuron.ref(propname).set(value);
        end
        function value = get_secondorder(~)
        % Get property secondorder.
        %   get_secondorder(propname)
            value = clib.neuron.get_secondorder();
        end
        function set_secondorder(~, value)
        % Set property secondorder.
        %   set_secondorder(propname, value)
            clib.neuron.set_secondorder(value);
        end

    end
    methods(Static)
        function value = call_func_hoc(func, returntype, varargin)
        % Call function by passing function name (func) to HOC lookup, along with its return type (returntype) and arguments (varargin).
        %   value = call_func_hoc(func, returntype, varargin)

            % Save state & try/catch in case the call fails.
            clib.neuron.increase_try_catch_nest_depth();
            state = clib.neuron.SavedState();
            try
                [nsecs, nargs] = neuron.stack.push_args(varargin{:});
                sym = clib.neuron.hoc_lookup(func);
                func_val = clib.neuron.hoc_call_func(sym, nargs);
                if (returntype=="double")
                    value = func_val;
                else
                    value = neuron.stack.hoc_pop(returntype);
                end
                neuron.stack.pop_sections(nsecs);
            catch e
                value = NaN;
                warning(e.message);
                warning("'"+string(func)+"': number or type of arguments incorrect.");
                state.restore();
            end
            clibRelease(state);
            clib.neuron.decrease_try_catch_nest_depth();

        end
        function obj = hoc_new_obj(objtype, varargin)
        % Make object by providing object type (objtype) and constructor arguments (varargin).
        %   obj = hoc_new_obj(objtype, varargin)

            % Save state & try/catch in case the call fails.
            clib.neuron.increase_try_catch_nest_depth();
            state = clib.neuron.SavedState();
            try
                if (objtype == "Vector") && (numel(varargin) == 1) && (numel(varargin{:}) > 1)
                    % Special case: construct Vector from list.
                    sym = clib.neuron.hoc_lookup("Vector");
                    cppobj = clib.neuron.hoc_newobj1(sym, 0);
                    obj = neuron.Vector(cppobj);
                    vector_data = varargin{:};
                    for i=1:numel(vector_data)
                        temp = obj.append(vector_data(i));
                        clear temp;
                    end
                else
                    % Generic case: push arguments to stack and create Object.
                    [nsecs, nargs] = neuron.stack.push_args(varargin{:});
                    sym = clib.neuron.hoc_lookup(objtype);
                    cppobj = clib.neuron.hoc_newobj1(sym, nargs);
                    if (objtype == "Vector")
                        obj = neuron.Vector(cppobj);
                    elseif (objtype == "PlotShape")
                        obj = neuron.PlotShape(cppobj);
                    elseif (objtype == "RangeVarPlot")
                        obj = neuron.RangeVarPlot(cppobj);
                    else
                        obj = neuron.Object(cppobj);
                    end
                    neuron.stack.pop_sections(nsecs);
                end
            catch e
                obj = NaN;
                warning(e.message);
                warning("'"+string(objtype)+"': number or type of arguments incorrect.");
                state.restore();
            end
            clibRelease(state);
            clib.neuron.decrease_try_catch_nest_depth();

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
        function all_sections = allsec(section_list, owner)
        % Return cell array containing all sections, or all sections in a NEURON
        % SectionList section_list (optional).
        % Boolean owner (optional, default: false).
        %   allsec()
        %   allsec(section_list)
        %   allsec(section_list, true)

            % Deal with input.
            if ~exist('section_list', 'var') % No input: get SectionList of all Sections.
                section_list = clib.neuron.get_section_list();
            elseif isa(section_list, 'neuron.Object') % Input is a 'n.SectionList'
                section_list = clib.neuron.get_obj_u_this_pointer(section_list.obj);
            elseif isa(section_list, 'clib.neuron.Object') % Input is a C++ NEURON object
                if clibIsNull(section_list) % If NULL, get SectionList of all Sections.
                    section_list = clib.neuron.get_section_list();
                else  % Input is a fair dinkum NEURON SectionList
                    section_list = clib.neuron.get_obj_u_this_pointer(section_list);
                end
            end

            if ~exist('owner', 'var')
                owner = false;
            end

            section_iter = section_list.next;
            section = clib.neuron.get_hoc_item_element_sec(section_iter);
            if clibIsNull(section)
                all_sections = {};
            else
                all_sections = {neuron.Section(section, owner)};
            
                % Iterate using section_iter.next.
                while true
                    section_iter = section_iter.next;
                    section = clib.neuron.get_hoc_item_element_sec(section_iter);
                    if clibIsNull(section)
                        % End of the section chain.
                        break;
                    else
                        if clibIsNull(section.prop)
                            % Invalidated section: do not append, delete and unref.
                            clib.neuron.hoc_l_delete(section_iter);
                            clib.neuron.section_unref(section);
                        else
                            % Valid section: append.
                            all_sections{end+1} = neuron.Section(section, owner);
                        end
                    end
                end
            end
        end

    end
end