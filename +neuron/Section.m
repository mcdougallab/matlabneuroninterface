classdef Section
% Section Class for manipulating Neuron sections.
    properties (Access=private)
        sec     % C++ Section object.
        name    % Name of the section.
    end
    properties (Dependent)
        length
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
                % clib.neuron.section_unref(self.sec); % TODO: do we need this?
                self.sec.refcount = 0;
                clib.neuron.nrn_pushsec(self.sec);
                clib.neuron.matlab_hoc_call_func("delete_section", 0);
                clib.neuron.nrn_sec_pop();
                clibRelease(self.sec);
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
        function change_nseg(self, nseg)
        % Change the number of segments in the Section.
        %   change_nseg(nseg)
            clib.neuron.nrn_change_nseg(self.sec, nseg);
        end
        function connect(self, loc0, sec1, loc1)
        % Connect this section at loc0 to another section (sec1) at loc1.
        %   connect(loc0, sec1, loc1)
            clib.neuron.connect(self.sec, loc0, sec1.get_sec(), loc1);
        end

        function addpoint(self, x, y, z, diam)
        % Add point to Section.
        %   addpoint(x, y, z, diam)
            clib.neuron.pt3dadd(self.sec, x, y, z, diam)
        end
        function self = set.length(self, val)
        % Set length of Section.
            clib.neuron.set_length(self.sec, val);
        end
        function value = get.length(self)
        % Get length of Section.
            % TODO: instead of a new function get_length(), this can also
            % be done with existing functions (pushsec, hoc_lookup("L"),
            % call_func(), secpop)
            value = clib.neuron.get_length(self.sec);
        end
        function self = set_diameter(self, val)
        % Set diameter of Section.
        %   set_diameter(val)
            clib.neuron.set_diameter(self.sec, val);
        end
        function info(self)
        % Print section info
        %   info()
            clib.neuron.print_3d_points_and_segs(self.sec)
        end
    end
end