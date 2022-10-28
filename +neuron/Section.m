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
                % clib.neuron.section_unref(self.sec);  % TODO: is this needed?
                % self.sec.refcount = 0;
                clib.neuron.nrn_pushsec(self.sec);
                clibRelease(self.sec);
                sym = clib.neuron.hoc_lookup("delete_section");
                clib.neuron.hoc_call_func(sym, 0);
                % It looks like delete_section already pops the section off the stack.
                % clib.neuron.nrn_sec_pop();
            end
        end
        function insert_mechanism(self, mech_name)
        % Insert a mechanism by providing a mechanism name.
        %   insert_mechanism(mech_name)
            sym = clib.neuron.hoc_lookup(mech_name);
            clib.neuron.mech_insert1(self.sec, sym.subtype);
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
        function connect(self, loc, parent_sec, parent_loc)
        % Connect this section at loc to another section (parent_sec) at parent_loc.
        %   connect(loc, parent_sec, parent_loc)
            clib.neuron.nrn_pushsec(self.sec);
            clib.neuron.hoc_pushx(loc);
            clib.neuron.nrn_pushsec(parent_sec.get_sec());
            clib.neuron.hoc_pushx(parent_loc);
            clib.neuron.simpleconnectsection();
        end

        function addpoint(self, x, y, z, diam)
        % Add point to Section.
        %   addpoint(x, y, z, diam)            
            clib.neuron.nrn_pushsec(self.sec);
            clib.neuron.hoc_pushx(x);
            clib.neuron.hoc_pushx(y);
            clib.neuron.hoc_pushx(z);
            clib.neuron.hoc_pushx(diam);
            sym = clib.neuron.hoc_lookup("pt3dadd");
            clib.neuron.hoc_call_func(sym, 4);
            clib.neuron.nrn_sec_pop();
        end
        function self = set.length(self, val)
        % Set length of Section.
            clib.neuron.set_dparam(self.sec, 2, val);
            clib.neuron.nrn_length_change(self.sec, val);
            clib.neuron.set_diam_changed(1);
            self.sec.recalc_area_ = 1;
        end
        function value = get.length(self)
        % Get length of Section.
            % We cannot directly access self.sec.prop.dparam, because it
            % is a union, which Matlab does not understand.
            value = clib.neuron.get_dparam(self.sec, 2);
        end
        function self = set_diameter(self, val)
        % Set diameter of Section.
        %   set_diameter(val)

            nseg = self.sec.nnode - 1;
            for i=1:nseg
                x = double((double(i) - 0.5) / double(nseg));
                node = clib.neuron.node_exact(self.sec, x);
                clib.neuron.set_node_diam(node, val);
            end

        end
        function psection(self)
        % Print psection info
        %   psection()
            clib.neuron.nrn_pushsec(self.sec);
            sym = clib.neuron.hoc_lookup("psection");
            clib.neuron.hoc_call_func(sym, 0);
            clib.neuron.nrn_sec_pop();
        end
        function info(self)
        % Print section info
        %   info()
            
            nseg = self.sec.nnode - 1;
            npt3d = self.sec.npt3d;
            disp(self.name + " has length " + self.length + ".");
            disp(self.name + " has " + npt3d + " pt3d and " ...
                + nseg + " segment(s).");
            for i=1:npt3d
                disp(self.sec.pt3d(i));
            end
            for i=1:nseg
                x = double((double(i) - 0.5) / double(nseg));
                disp(self.name + "(" + x + ").v = " ...
                    + self.ref("v", x).get());
                disp(self.name + "(" + x + ").diam = " ...
                    + self.ref("diam", x).get());
            end

        end
    end
end