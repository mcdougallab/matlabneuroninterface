classdef NrnRef < handle
% Neuron reference (NrnRef) wrapper class

    properties (SetAccess=protected, GetAccess=public)
        obj             % C++ NrnRef object.
    end
    
    methods
        function self = NrnRef(obj)
        % Initialize NrnRef
        %   NrnRef(obj) constructs a Matlab wrapper for C++ NrnRef obj
            self.obj = obj;
        end
        function value = get(self, ind)
            if exist('ind', 'var')
                value = self.obj.get_index(ind - 1);
            else
                value = self.obj.get();
            end
        end
        function self = set(self, value, ind)
            if exist('ind', 'var')
                self.obj.set_index(value, ind - 1);
            else
                self.obj.set(value);
            end
        end
        % Allow for access by index.
        function varargout = subsref(self, S)
            if S(1).type == "()"
                [varargout{1:nargout}] = self.get(S(1).subs{:});
                n_processed = 1;
            else
                [varargout{1:nargout}] = builtin('subsref', self, S(1:2));
                n_processed = 2;
            end
            if numel(S) > n_processed
                % Deal with a method/attribute call chain.
                [varargout{1:nargout}] = varargout{:}.subsref(S(n_processed+1:end));
            end
        end
        function self = subsasgn(self, S, varargin)
            if S(1).type == "()"
                self.set(varargin{:}, S(1).subs{:});
            else
                self = builtin('subsasgn', self, S, varargin{:});
            end
        end
    end

end
