classdef Section
    properties (Access=public)
        sec
        name
    end
    methods
        function obj = Section(name)
            obj.name = name;
            obj.sec = clib.neuron.new_section(name);
        end
        function insert_mechanism(obj, mech_name)
            clib.neuron.insert_mechanism(obj.sec, mech_name);
        end
    end
end