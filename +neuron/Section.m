classdef Section
% Section Class for manipulating Neuron sections.
    properties (Access=private)
        sec     % C++ Section object.
    end
    properties (Access=public)
        name    % Name of the section.
    end
    methods
        function self = Section(name)
        % Initialize a new Section by providing a name.
        %   Section(name) 
            if clib.neuron.isinitialized()
                self.name = name;
                self.sec = clib.neuron.new_section(name);
            else
                self.name = name;
                warning("Initialize a Neuron session before making a Section.");
            end
        end
        function delete(self)
        % Destroy the Section object.
        %   delete()
            if (class(self.sec) == "clib.neuron.Section")
                clib.neuron.section_unref(self.sec);
                clibRelease(self.sec)
            end
        end
        function insert_mechanism(self, mech_name)
        % Insert a mechanism by providing a mechanism name.
        %   insert_mechanism(mech_name)
            clib.neuron.insert_mechanism(self.sec, mech_name);
        end
        function nrnref = ref(self, sym, loc)
        % Return an NrnRef to a quantity (sym) at a location along the segment (loc) between 0 and 1.
        %   nrnref = ref(sym, loc) 
            nrnref = clib.neuron.range_ref(self.sec, sym, loc);
        end
        function sec = get_sec(self)
        % Return the C++ Section object.
        %   sec = get_sec() 
            sec = self.sec;
        end
    end
end