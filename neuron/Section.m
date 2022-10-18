% The Section class allows us to manipulate Neuron sections.

classdef Section
    properties (Access=private)
        sec
    end
    properties (Access=public)
        name
    end
    methods
        function self = Section(name)
        % Initialize a new Section by providing a Section name.
            self.name = name;
            self.sec = clib.neuron.new_section(name);
        end
        function insert_mechanism(self, mech_name)
        % Insert mechanism by providing a mechanism name.
            clib.neuron.insert_mechanism(self.sec, mech_name);
        end
        function value = ref(self, sym, val)
        % Get a NrnRef containing a pointer to a quantity (sym) at a
        % location along the segment (val) between 0 and 1.
            value = clib.neuron.range_ref(self.sec, sym, val);
        end
    end
end