classdef Section < handle
% Section Class for manipulating Neuron sections.
    properties (Access=private)
        sec         % C++ Section object.
    end
    properties (SetAccess=protected, GetAccess=public)
        mech_list   % List of allowed insertable mechanisms.
        range_list  % List of allowed range variables.
        owner       % Set to false if Matlab section does not own Neuron section, 
                    % i.e., if destroying the Matlab object should not
                    % trigger C++ object destruction.
    end
    properties (Dependent)
        length      % Section length.
        nseg        % Number of segments.
        name        % Name of the section.
    end
    methods
        function self = Section(value, owner)
        % Initialize a new Section by providing a name or Neuron section
        % object. The optional 'owner' argument is a boolean - if set to true
        % (default value) the C++ Section object is destroyed upon
        % destroying the Matlab Section; if set to false, the C++ Section
        % is kept in place.
        %   Section(name) 
        %   Section(cppobj)
        %   Section(cppobj, false)
            if clib.neuron.isinitialized()
                % Check if input is a section name (string/char)
                if (isa(value, "string") || isa(value, "char"))
                    name = value;
                    self.sec = clib.neuron.new_section(name);
                elseif isa(value, "clib.neuron.Section")
                    sec = value;
                    self.sec = sec;
                else
                    error("Invalid input for Section constructor.")
                end
                if exist('owner', 'var')
                    self.owner = owner;
                else
                    self.owner = true;
                end
                self.mech_list = [];
                self.range_list = [];

                arr = split(clib.neuron.get_nrn_functions(), ";");
                arr = arr(1:end-1);
    
                % Add dynamic mechanisms and range variables.
                % See: doc/DEV_README.md#neuron-types
                for i=1:length(arr)
                    var = split(arr(i), ":");
                    var_types = split(var(2), "-");
                    var_type = var_types(1);
                    % var_subtype = var_types(2);
                    if (var_type == "310") % range variable
                        self.range_list = [self.range_list var(1)];
                    elseif (var_type == "311") % insertable mechanism
                        self.mech_list = [self.mech_list var(1)];
                    end
                end

            else
                error("Initialize a Neuron session before making a Section.");
            end
        end
        
        function delete_nrn_sec(self)
        % Destroy the Neuron Section.
        %   delete_nrn_sec()
            % clib.neuron.section_unref(self.sec);  % Not necessary.
            self.push();
            clib.neuron.hoc_oc("{delete_section()}");
            % neuron.stack.pop_sections(1);  % Not necessary.
        end

        function delete(self)
        % Destroy the Section object.
        %   delete()
            if self.owner
                if ~clibIsNull(self.sec.prop)
                    self.delete_nrn_sec();
                else
                    warning('Attempting to delete Section that was already deleted.');
                end
            end
        end

        function self = subsasgn(self, S, varargin)
        % Implement assigning Section and Segment properties.

            % Are we trying to directly access a class property?
            if (isa(S(1).subs, "char") && length(S) == 1 && isprop(self, S(1).subs))
                self.(S(1).subs) = varargin{:};
            % Assign a segment property value.
            elseif (S(1).type == "()" && length(S) == 2)
                x = S(1).subs{:};
                seg = neuron.Segment(self, x);
                seg.(S(2).subs) = varargin{:};
            end
        end

        function varargout = subsref(self, S)
        % Implement indexing, returning a Segment.

            % S(1).subs is method (or property) name;
            % S(2).subs is a cell array containing arguments.


            if S(1).type == "."
                % Are we trying to directly access a class property?
                if isprop(self, S(1).subs)
                    [varargout{1:nargout}] = self.(S(1).subs);
                    n_processed = 1;  % Number of elements of S to process.
                elseif numel(S) > 1
                    % Is the provided method listed above?
                    if ismethod(self, S(1).subs)
                        [varargout{1:nargout}] = builtin('subsref', self, S(1:2));
                        n_processed = 2;  % Number of elements of S to process.
                    else
                        error("Section."+string(S(1).subs)+" not found.")
                    end
                else
                    error("Section."+string(S(1).subs)+" not found.")
                end
            % Are we trying to get a Segment by using ()-indexing?
            elseif S(1).type == "()"
                x = S(1).subs{:};
                [varargout{1:nargout}] = neuron.Segment(self, x);
                n_processed = 1;  % Number of elements of S to process.
            % Other indexing types ({}) not supported.
            else
                error("Indexing type "+S(1).type+" not supported.");
            end
            if numel(S) > n_processed
                % Deal with a method/attribute call chain.
                if numel(varargout) == 1
                    [varargout{1:nargout}] = varargout{:}.subsref(S(n_processed+1:end));
                elseif numel(varargout) == 0
                    error("Cannot run chained method call on empty method output.");
                else
                    error("Cannot run chained method call on multiple method outputs.");
                end
            end
        end
        function arr = segment_locations(self, endpoints)
        % Return array of all section segment locations; set endpoints 
        % (optional) to true to include endpoints 0 and 1.
        %   arr = segment_locations()
        %   arr = segment_locations(true)
            if (exist('endpoints', 'var') && (endpoints == true))
                arr = zeros(1, self.nseg + 2);
                arr(1) = 0;
                arr(end) = 1;
                offset = 1;
            else
                arr = zeros(1, self.nseg);
                offset = 0;
            end
            for i=1:self.nseg
                segment = (double(i-1) + 0.5) / double(self.nseg);
                arr(offset + i) = segment;
            end
        end
        function segs = segments(self, endpoints)
        % Return cell array with Segments; set endpoints 
        % (optional) to true to include endpoints 0 and 1.
        %   segs = segments()
        %   segs = segments(true)
            if (exist('endpoints', 'var') && (endpoints == true))
                x_arr = self.segment_locations(endpoints);
            else
                x_arr = self.segment_locations();
            end
            segs = cell(size(x_arr));
            for i=1:numel(x_arr)
                segs{i} = neuron.Segment(self, x_arr(i));
            end
        end
        function segs = allseg(self)
        % Return cell array with all Segments, including endpoints; alias 
        % for segs = segments(true).
        %   segs = allseg()
            segs = self.segments(true);
        end
        function insert_mechanism(self, mech_name)
        % Insert a mechanism by providing a mechanism name.
        %   insert_mechanism(mech_name)
            if any(strcmp(self.mech_list, mech_name))
                sym = clib.neuron.hoc_lookup(mech_name);
                clib.neuron.mech_insert1(self.sec, sym.subtype);
            else
                error("Insertable mechanism '"+mech_name+"' not found.");
                disp("Available insertable mechanisms:")
                for i=1:self.mech_list.length()
                    disp("    "+self.mech_list(i));
                end
            end
        end
        function insert(self, mech_name)
        % Alias for insert_mechanism.
            self.insert_mechanism(mech_name);
        end
        function nrnref = ref(self, rangevar, loc)
        % Return an NrnRef to a range variable (rangeref) at a location 
        % along the segment (loc) between 0 and 1.
        %   nrnref = ref(rangevar, loc) 
            if any(strcmp(self.range_list, rangevar))
                nrnref = clib.neuron.range_ref(self.sec, rangevar, loc);
                nrnref = neuron.NrnRef(nrnref);
            else
                warning("Range variable '"+rangevar+"' not found.");
                disp("Available range variables:")
                for i=1:self.range_list.length()
                    disp("    "+self.range_list(i));
                end
            end
        end
        function sec = get_sec(self)
        % Return the C++ Section object.
        %   sec = get_sec() 
            sec = self.sec;
        end
        function connect(self, loc, varargin)
            % Connect this section at loc to another section (parent_sec) at parent_loc.
            %   connect(loc, parent_sec, parent_loc)
            %   connect(parent_sec)  % connects the 0 location to the 1 of
            %   the parent
            if nargin > 2
                parent_sec = varargin{1};
                parent_loc = varargin{2};
            else
                parent_sec = loc;
                loc = 0;
                parent_loc = 1;
            end
            clib.neuron.nrn_pushsec(self.sec);
            clib.neuron.hoc_pushx(loc);
            clib.neuron.nrn_pushsec(parent_sec.get_sec());
            clib.neuron.hoc_pushx(parent_loc);
            clib.neuron.simpleconnectsection();
        end

        function push(self)
        % Push self to Section stack.
        %   push()
            clib.neuron.nrn_pushsec(self.sec);
        end

        function addpoint(self, x, y, z, diam)
        % Add point to Section.
        %   addpoint(x, y, z, diam)            
            self.push();
            clib.neuron.hoc_pushx(x);
            clib.neuron.hoc_pushx(y);
            clib.neuron.hoc_pushx(z);
            clib.neuron.hoc_pushx(diam);
            sym = clib.neuron.hoc_lookup("pt3dadd");
            clib.neuron.hoc_call_func(sym, 4);
            neuron.stack.pop_sections(1);
        end
        function set.length(self, val)
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
        function value = get.name(self)
        % Get Section name.
            value = clib.neuron.secname(self.sec);
        end
        function self = set.nseg(self, val)
        % Set the number of segments in the Section.
            clib.neuron.nrn_change_nseg(self.sec, val);
        end
        function value = get.nseg(self)
        % Get the number of segments in the Section.
            value = self.sec.nnode - 1;
        end
        function self = set_diameter(self, val)
        % Set diameter of Section.
        %   set_diameter(val)

            for i=1:self.nseg
                x = double((double(i) - 0.5) / double(self.nseg));
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
        function pt3d = get_pt3d(self)
        % Get all 3D point information; returns a 5xN matrix for N 3D
        % points, with rows [x, y, z, arc, d].
        %   pt3d = get_pt3d()
            npt3d = self.sec.npt3d;
            x3d = zeros(1, npt3d);
            y3d = zeros(1, npt3d);
            z3d = zeros(1, npt3d);
            arc3d = zeros(1, npt3d);
            d3d = zeros(1, npt3d);
            for j=1:npt3d
                pt = self.sec.pt3d(j);
                x3d(j) = pt.x;
                y3d(j) = pt.y;
                z3d(j) = pt.z;
                arc3d(j) = pt.arc;
                d3d(j) = pt.d;
            end
            pt3d = [x3d; y3d; z3d; arc3d; d3d];
        end
        function info(self)
        % Print section info
        %   info()
            
            npt3d = self.sec.npt3d;
            disp(self.name + " has length " + self.length + ".");
            disp(self.name + " has " + npt3d + " pt3d and " ...
                + self.nseg + " segment(s).");
            for i=1:npt3d
                disp(self.sec.pt3d(i));
            end
            segments = self.segments();
            for i=1:self.nseg
                seg = segments{i};
                disp(self.name + "(" + seg.x + ").v = " + seg.v);
                disp(self.name + "(" + seg.x + ").diam = " + seg.diam);
            end

        end
    end
end
