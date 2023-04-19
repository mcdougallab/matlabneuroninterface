classdef Segment < handle
% Section Class for manipulating Neuron sections.
    properties (Access=private)
        parent_sec    % MATLAB section object.
    end
    properties (SetAccess=protected, GetAccess=public)
        x           % Number between 0 and 1: location on the Section.
        on_stack    % Boolean, keeping track if we are on the stack.
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
            self.on_stack = false;
        end
        function value = push(self)
        % Push Segment to NEURON stack; returns true if successful. 
        %   value = push()
            if ~self.on_stack
                % TODO: Does this go wrong if we push another Segment on
                % the same Section?
                clib.neuron.nrn_pushsec(self.parent_sec.get_sec());
                neuron.stack.hoc_push(self.x);
                self.on_stack = true;
                value = self.on_stack;
            else
                warning("Cannot push Segment: Segment already on NEURON stack.");
                value = false;
            end
        end
        function pop(self)
        % Pop Segment from NEURON stack
        %   pop()
            if self.on_stack
                clib.neuron.nrn_sec_pop();
                self.on_stack = false;
            else
                warning("Cannot pop Segment: Segment not on NEURON stack.");
            end
        end
        function nrnref = ref(self, rangevar)
            nrnref = self.parent_sec.ref(rangevar, self.x);
        end
        function value = get.parent_name(self)
            value = self.parent_sec.name;
        end
    end
end