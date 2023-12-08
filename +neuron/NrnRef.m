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
        function value = get(self)
            value = self.obj.get();
        end
        function set(self, value)
            self.obj.set(value);
        end
        % Allow for access by index (1).
        function varargout = subsref(self, s)
            if s(1).type == '()'  % TODO: check if index is correct?
                [varargout{1:nargout}] = self.get();
            else
                [varargout{1:nargout}] = builtin('subsref', self, s);
            end
        end
        function self = subsasgn(self, s, varargin)
            disp(s);
            if s(1).type == '()'
                self.set(varargin{:});
            else
                self = builtin('subsasgn', self, s, varargin{:});
            end
        end
    end

end
