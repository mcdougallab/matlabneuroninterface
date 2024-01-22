classdef Segment < handle
% Segment Class for manipulating parts of Sections.
    properties (SetAccess=protected, GetAccess=public)
        parent_sec      % MATLAB section object.
        x               % Number between 0 and 1: location on the Section.
    end
    properties (Dependent)
        parent_name     % String; name of parent section.
    end
    methods
        function self = Segment(sec, x)
        % Initialize a new Segment by providing a Section and location value.
        %   Segment(sec, x) 
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
        % Get reference to range variable on segment.
        %   nrnref = ref(rangevar)
            nrnref = self.parent_sec.ref(rangevar, self.x);
        end
        function value = get.parent_name(self)
        % Get parent_name property.
            value = self.parent_sec.name;
        end

        function varargout = subsref(self, S)
        % Call a class method or dynamic property.
            if S(1).type == "."
                % Are we trying to directly access a class property?
                if isprop(self, S(1).subs)
                    [varargout{1:nargout}] = self.(S(1).subs);
                    n_processed = 1;  % Number of elements of S to process.
                % Is the provided method listed above?
                elseif numel(S) > 1 && ismethod(self, S(1).subs)
                    [varargout{1:nargout}] = builtin('subsref', self, S(1:2));
                    n_processed = 2;  % Number of elements of S to process.
                % Is it a Section range ref?
                elseif any(strcmp(self.parent_sec.range_list, S(1).subs))
                    ref = self.ref(S(1).subs);
                    [varargout{1:nargout}] = ref.get();
                    n_processed = 1;  % Number of elements of S to process.
                else
                    error("Method/property "+S(1).subs+" not recognized.");
                end
            % Other indexing types ({} or ()) not supported.
            else
                error("Indexing type "+S(1).type+" not supported.");
            end
            [varargout{1:nargout}] = neuron.chained_method(varargout, S, n_processed);
        end

        function self = subsasgn(self, S, varargin)
        % Assign a (dynamic) property value.
            % Are we trying to directly access a class property?
            if (isa(S(1).subs, "char") && length(S) == 1 && isprop(self, S(1).subs))
                self.(S(1).subs) = varargin{:};
            elseif (isa(S(1).subs, "char") && length(S) == 1)
                ref = self.ref(S(1).subs);
                ref.set(varargin{:});
            end
        end

        function [x_lo, x_hi] = get_bounds(self)
        % Get start and end bounds of Segment.
            nseg = double(self.parent_sec.nseg);
            x_lo = floor(nseg*self.x) / double(self.parent_sec.nseg);
            x_hi = ceil(nseg*self.x) / double(self.parent_sec.nseg);
        end
    end
end