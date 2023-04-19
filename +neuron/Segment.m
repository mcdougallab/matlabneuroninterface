classdef Segment < handle
% Section Class for manipulating Neuron sections.
    properties (Access=private)
        parent_sec  % C++ section object.
    end
    properties (SetAccess=protected, GetAccess=public)
        parent_name % String; name of parent section.
        x           % Number between 0 and 1: location on the Section.
        on_stack    % Boolean, keeping track if we are on the stack.
    end
    methods
        function self = Segment(sec, x)
        % Initialize a new Segment by providing a Section and location value.
        %   Section(sec, x) 
            self.parent_sec = sec.get_sec();
            self.parent_name = sec.name;
            self.x = x;
            self.on_stack = false;
        end
        function value = push(self)
        % Push Segment to NEURON stack; returns true if successful. 
        %   value = push()
            if ~self.on_stack
                % TODO: Does this go wrong if we push another Segment on
                % the same Section?
                clib.neuron.nrn_pushsec(self.parent_sec);
                neuron.hoc_push(self.x);
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
    end
end