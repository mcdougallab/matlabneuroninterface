classdef Segment < handle
% Section Class for manipulating Neuron sections.
    properties (Access=private)
        parent_sec    % MATLAB section object.
    end
    properties (SetAccess=protected, GetAccess=public)
        x           % Number between 0 and 1: location on the Section.
    end
    properties (Dependent)
        parent_name % String; name of parent section.
    end
    methods
        function self = Segment(sec, x)
        % Initialize a new Segment by providing a Section and location value.
        %   Section(sec, x) 
            self.parent_sec = sec;
            self.x = x;
        end
        function push(self)
        % Push Segment to NEURON stack. 
        %   value = push()
            clib.neuron.nrn_pushsec(self.parent_sec.get_sec());
            neuron.stack.hoc_push(self.x);
        end
        function nrnref = ref(self, rangevar)
            nrnref = self.parent_sec.ref(rangevar, self.x);
        end
        function value = get.parent_name(self)
            value = self.parent_sec.name;
        end

        function varargout = subsref(self, S)
            % Is the provided method listed above?
            if ismethod(self, S(1).subs)
                [varargout{1:nargout}] = builtin('subsref', self, S);
            % Are we trying to directly access a class property?
            elseif (isa(S(1).subs, "char") && length(S) == 1 && isprop(self, S(1).subs))
                [varargout{1:nargout}] = self.(S(1).subs);
            % If not a class property, return a Section range ref
            elseif (isa(S(1).subs, "char") && length(S) == 1)
                ref = self.ref(S(1).subs);
                [varargout{1:nargout}] = ref.get();
            else
                warning("Section."+string(S(1).subs)+" not found.")
            end
        end

        function self = subsasgn(self, S, varargin)
            % Are we trying to directly access a class property?
            if (isa(S(1).subs, "char") && length(S) == 1 && isprop(self, S(1).subs))
                self.(S(1).subs) = varargin{:};
            elseif (isa(S(1).subs, "char") && length(S) == 1)
                ref = self.ref(S(1).subs);
                ref.set(varargin{:});
            end
        end

    end
end