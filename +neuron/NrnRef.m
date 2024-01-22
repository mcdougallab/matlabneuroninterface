classdef NrnRef < handle
% Neuron reference (NrnRef) wrapper class. The referenced value can be
% accessed by indexing, e.g. ```t = n.ref('t'); disp(t(1));```.

    properties (SetAccess=protected, GetAccess=public)
        obj             % C++ NrnRef object.
    end
    properties (Dependent)
        length          % Data length.
    end
    
    methods
        function self = NrnRef(obj)
        % Initialize NrnRef
        %   NrnRef(obj) constructs a Matlab wrapper for C++ NrnRef obj
            self.obj = obj;
        end
        function value = get(self, ind)
        % Get value.
        %   value = get()
        %   value = get(index)
            if exist('ind', 'var')
                value = self.obj.get_index(ind - 1);
            else
                value = self.obj.get();
            end
        end
        function self = set(self, value, ind)
        % Set value.
        %   set(value)
        %   set(value, index)
            if exist('ind', 'var')
                self.obj.set_index(value, ind - 1);
            else
                self.obj.set(value);
            end
        end
        function value = get.length(self)
            value = self.obj.n_elements;
        end
        function set.length(self, n)
            self.obj.n_elements = n;
        end
        function sz = size(self)
            x = 1;
            y = self.length;
            sz = [x y];
        end
        function value = numel(self)
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
                self = builtin('subsasgn', self, S, varargin{:});
            else
                % Other indexing type ({}) not supported.
                error("Indexing type "+S(1).type+" not supported.");
            end
        end
    end

end
