classdef Section
    properties (Access=public)
        sec
        name
    end
    methods
        function self = Section(name)
            self.name = name;
            self.sec = clib.neuron.new_section(name);
        end
        function insert_mechanism(self, mech_name)
            clib.neuron.insert_mechanism(self.sec, mech_name);
        end
    end
end