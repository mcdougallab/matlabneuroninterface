classdef NrnRef < handle
% NEURON reference (NrnRef) wrapper class. The referenced value can be
% accessed by indexing, e.g. ```t = n.ref('t'); disp(t(1));```.

    properties (SetAccess=protected, GetAccess=public, Hidden)
        obj             % C++ NrnRef object.
    end
    properties (Dependent, SetAccess=protected)
        ref             % Name of what is referenced.
        ref_class       % Class of what is referenced.
        length          % Data length.
    end
    
    methods
        function self = NrnRef(obj)
        % Initialize NrnRef
        %   NrnRef(obj) constructs a Matlab wrapper for C++ NrnRef obj
            self.obj = obj;
            disp(obj);
        end
        function value = get(self, ind)
        % Get value.
        %   value = get()
        %   value = get(index)
            if exist('ind', 'var')
                if strcmp(self.ref_class, "Vector")
                    value = neuron_api('nrnref_vector_get', self.obj, ind - 1);
                elseif strcmp(self.ref_class, "Symbol")
                    value = neuron_api('nrnref_symbol_get', self.obj, ind - 1);
                elseif strcmp(self.ref_class, "ObjectProp")
                    value = neuron_api('nrnref_property_get', self.obj, ind - 1);
                elseif strcmp(self.ref_class, "RangeVar")
                    value = neuron_api('nrnref_rangevar_get', self.obj, ind - 1);
                end
            else
                if strcmp(self.ref_class, "Vector")
                    value = neuron_api('nrnref_vector_get', self.obj, 0);
                elseif strcmp(self.ref_class, "Symbol")
                    value = neuron_api('nrnref_symbol_get', self.obj, 0);
                elseif strcmp(self.ref_class, "ObjectProp")
                    value = neuron_api('nrnref_property_get', self.obj, 0);
                elseif strcmp(self.ref_class, "RangeVar")
                    value = neuron_api('nrnref_rangevar_get', self.obj, 0);
                end
            end
        end
        function self = set(self, value, ind)
        % Set value.
        %   set(value)
        %   set(value, index)
            if exist('ind', 'var')
                if strcmp(self.ref_class, "Vector")
                    neuron_api('nrnref_vector_set', self.obj, value, ind - 1);
                elseif strcmp(self.ref_class, "Symbol")
                    neuron_api('nrnref_symbol_set', self.obj, value, ind - 1);
                elseif strcmp(self.ref_class, "ObjectProp")
                    neuron_api('nrnref_property_set', self.obj, value, ind - 1);
                elseif strcmp(self.ref_class, "RangeVar")
                    neuron_api('nrnref_rangevar_set', self.obj, value, ind - 1);
                end
            else
                if strcmp(self.ref_class, "Vector")
                    neuron_api('nrnref_vector_set', self.obj, value, 0);
                elseif strcmp(self.ref_class, "Symbol")
                    neuron_api('nrnref_symbol_set', self.obj, value, 0);
                elseif strcmp(self.ref_class, "ObjectProp")
                    neuron_api('nrnref_property_set', self.obj, value, 0);
                elseif strcmp(self.ref_class, "RangeVar")
                    neuron_api('nrnref_rangevar_set', self.obj, value, 0);
                end
            end
        end
        function value = get.length(self)
            value = neuron_api('nrnref_get_n_elements', self.obj);
        end
        function value = get.ref(self)
            name = neuron_api('nrnref_get_name', self.obj);
            if ~isempty(name)
                value = name;
            elseif (self.ref_class == "Vector")
                value = 'no label assigned';
            end
        end
        function value = get.ref_class(self)
            value = neuron_api('nrnref_get_class', self.obj);
        end
        
        function sz = size(self)
            x = 1;
            y = self.length;
            sz = [x y];
        end
        function value = numel(self, varargin)
            value = self.length;
        end
        % Allow for access by index.
        function varargout = subsref(self, S)
            if S(1).type == "()"
                [varargout{1:nargout}] = self.get(S(1).subs{:});
                n_processed = 1;
            elseif S(1).type == "."
                % Are we calling a built in class method?
                if numel(S) > 1 && ismethod(self, S(1).subs)
                    [varargout{1:nargout}] = builtin('subsref', self, S(1:2));
                    n_processed = 2;
                % Are we trying to directly access a class property?
                elseif isprop(self, S(1).subs)
                    [varargout{1:nargout}] = self.(S(1).subs);
                    n_processed = 1;
                else
                    error("Method/property "+S(1).subs+" not recognized.");
                end
            else
                % Other indexing type ({}) not supported.
                error("Indexing type "+S(1).type+" not supported.");
            end
            [varargout{1:nargout}] = neuron.chained_method(varargout, S, n_processed);
        end
        function self = subsasgn(self, S, varargin)
            if S(1).type == "()"
                self.set(varargin{:}, S(1).subs{:});
            elseif S(1).type == "."
                if any(strcmp(S(1).subs, {'obj', 'ref', 'ref_class', 'length'}))
                    error("Property '%s' is read-only and cannot be set after construction.", S(1).subs);
                end
                self = builtin('subsasgn', self, S, varargin{:});
            else
                % Other indexing type ({}) not supported.
                error("Indexing type "+S(1).type+" not supported.");
            end
        end
    end

end
