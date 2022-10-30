classdef Object < dynamicprops
% Neuron Object Class

    properties (Access=protected)
        objtype         % Neuron Object type
        obj             % C++ Neuron Object.
        method_list     % List of methods of the C++ object.
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
                method_str = clib.neuron.get_class_methods(self.objtype);
                self.method_list = split(method_str, ";");
                self.method_list = self.method_list(1:end-1);
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
            
            try
                n = length(varargin);
                for i=1:n
                    neuron.hoc_push(varargin{i});
                end
                sym = clib.neuron.hoc_table_lookup(method, ...
                    self.obj.ctemplate.symtable);
                clib.neuron.hoc_call_ob_proc(self.obj, sym, n);
                value = neuron.hoc_pop(returntype);
            % TODO: if the above code fails, Matlab often just crashes instead of catching an error.
            catch  
                warning("'"+string(method)+"': number or type of arguments incorrect.")
            end

        end

        function list_methods(self)
        % List all available methods to be called using HOC lookup.
        %   list_methods()
            warning("For now, only methods with type 270 (double), 329 (object) or 330 (string) can be called.");
            for i=1:length(self.method_list)
                mth = self.method_list(i).split(":");
                disp("Name: " + mth(1) + ", type: " + mth(2));
            end
        end

        function varargout = subsref(self, S)
        % If a method is called, but it is not listed above, try to run it by calling self.call_method_hoc().

            % S(1).subs is method name;
            % S(2).subs is a cell array containing arguments.
            method = S(1).subs;

            % Is the provided method listed above?
            if any(strcmp(methods(self), method))
                [varargout{1:nargout}] = builtin('subsref', self, S);
            % Special case: size
            % If we make an array of Objects, and ask for its size, Matlab
            % throws an error if we don't exclude this special case here.
            elseif (method == "size")
                % Do nothing.
            % Is this method present in the HOC lookup table, and does it return a double?
            elseif any(strcmp(self.method_list, method+":270"))
                [varargout{1:nargout}] = call_method_hoc(self, method, "double", S(2).subs{:});
            % Is this method present in the HOC lookup table, and does it return an object?
            elseif any(strcmp(self.method_list, method+":329"))
                [varargout{1:nargout}] = call_method_hoc(self, method, "Object", S(2).subs{:});  
            % Is this method present in the HOC lookup table, and does it return a string?
            elseif any(strcmp(self.method_list, method+":330"))
                [varargout{1:nargout}] = call_method_hoc(self, method, "string", S(2).subs{:});
            else
                warning("'"+string(method)+"': not found; call Object.list_methods() to see all available methods.")
            end
        end

    end
end