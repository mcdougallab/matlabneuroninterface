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
            if ~isa(sec, 'neuron.Section')
                error("First argument must be a neuron.Section object.");
            end
            if ~isnumeric(x) || ~isscalar(x) || x < 0 || x > 1
                error("Second argument must be a scalar number between 0 and 1.");
            end
            self.parent_sec = sec;
            self.x = x;
        end

        function disp(self)
            if numel(self) == 1
                try
                    if ~neuron_api('nrn_section_is_active', self.parent_sec.get_sec())
                        error();
                    else
                        builtin('disp', self);
                    end
                catch
                    error("Parent section has been deleted.");
                end
            else
                builtin('disp', self);
            end
        end

        function push(self)
        % Push Segment to NEURON stack. 
        %   value = push()
            neuron_api('nrn_section_push', self.parent_sec.get_sec());
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
            % If S(1).subs is 1, just return the object itself (for obj(1) syntax)
            
            if numel(self) > 1
                % Let MATLAB handle indexing arrays of Sections
                varargout = {builtin('subsref', self, S)};
                return
            end

            try
                if ~neuron_api('nrn_section_is_active', self.parent_sec.get_sec())
                    error();
                end
            catch
                error("Parent section has been deleted.");
            end
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
                    [varargout{1:nargout}] = neuron_api('nrn_rangevar_get', self.parent_sec.get_sec(), S(1).subs, self.x);
                    n_processed = 1;  % Number of elements of S to process.
                else
                    error("Method/property "+S(1).subs+" not recognized.");
                end
            % Other indexing types ({} or ()) not supported.
            elseif isnumeric(S(1).subs{:}) && isequal(S(1).subs{:}, 1)
                [varargout{1:nargout}] = self;
                n_processed = 1;
            else
                error("Indexing type "+S(1).type+" not supported.");
            end
            [varargout{1:nargout}] = neuron.chained_method(varargout, S, n_processed);
        end

        function self = subsasgn(self, S, varargin)
        % Assign a (dynamic) property value.

            try
                if ~neuron_api('nrn_section_is_active', self.parent_sec.get_sec())
                    error();
                end
            catch
                error("Parent section has been deleted.");
            end
            
            % Are we trying to directly access a class property?
            if (isa(S(1).subs, "char") && length(S) == 1 && isprop(self, S(1).subs))
                if any(strcmp(S(1).subs, {'parent_sec', 'x', 'parent_name'}))
                    error("Property '%s' is read-only and cannot be set after construction.", S(1).subs);
                end
                self.(S(1).subs) = varargin{:};
            elseif (isa(S(1).subs, "char") && length(S) == 1)
                % Only set if it is a valid range variable
                if any(strcmp(self.parent_sec.range_list, S(1).subs))
                    neuron_api('nrn_rangevar_set', self.parent_sec.get_sec(), S(1).subs, self.x, varargin{:});
                else
                    error("'%s' is not a valid range variable for this section.", S(1).subs);
                end
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