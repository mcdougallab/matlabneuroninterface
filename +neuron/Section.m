classdef Section < handle
% Section Class for manipulating NEURON sections.
    properties (Access=private)
        sec         % C++ Section object.
    end
    properties (SetAccess=protected, GetAccess=public)
        mech_list   % List of allowed insertable mechanisms.
        range_list  % List of allowed range variables.
        owner       % Set to false if Matlab section does not own NEURON section, 
                    % i.e., if destroying the Matlab object should not
                    % trigger C++ object destruction.
    end
    properties (Dependent)
        L           % Section length.
        nseg        % Number of segments.
        Ra          % Axial resistance.
        diam        % Diameter.
        rallbranch  % Rall branch property.
        name        % Name of the section.
    end
    methods
        function self = Section(value, owner)
        % Initialize a new Section by providing a name or NEURON section
        % object. The optional 'owner' argument is a boolean - if set to true
        % (default value) the C++ Section object is destroyed upon
        % destroying the Matlab Section; if set to false, the C++ Section
        % is kept in place.
        %   Section(name) 
        %   Section(cppobj)
        %   Section(cppobj, false)
            % Check if input is a section name (string/char)
            if (isa(value, "string") || isa(value, "char"))
                name = value;
                self.sec = neuron_api('nrn_section_new', name);
            elseif isa(value, "uint64")
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
            arr = split(neuron_api('get_nrn_functions'), ";");
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
        end

        function disp(self)
            try
                if ~neuron_api('nrn_section_is_active', self.sec)
                    error();
                else
                    builtin('disp', self);
                end
            catch
                error("Section has been deleted.");
            end
        end
        
        function delete_nrn_sec(self)
        % Destroy the NEURON Section.
        %   delete_nrn_sec()
            self.push();
            neuron_api('nrn_function_call', 'delete_section', 0);

            % neuron.stack.pop_sections(1);  % Not necessary.
        end

        function delete(self)
        % Destroy the Section object.
        %   delete()
            if self.owner
                if (neuron_api('nrn_section_is_active', self.sec))
                    self.delete_nrn_sec();
                end
            end
        end

        function self = subsasgn(self, S, varargin)
        % Implement assigning Section and Segment properties.

            % Check if section has been deleted.
            try
                if ~neuron_api('nrn_section_is_active', self.sec)
                    error();
                end
            catch
                error("Section has been deleted.");
            end

            % Are we trying to directly access a class property?
            if (isa(S(1).subs, "char") && length(S) == 1 && isprop(self, S(1).subs))
                % Prevent assignment to read-only properties
                if any(strcmp(S(1).subs, {'mech_list', 'range_list', 'owner', 'sec'}))
                    error("Property '%s' is read-only and cannot be set after construction.", S(1).subs);
                end
                self.(S(1).subs) = varargin{:};
            % Assign a segment property value.
            elseif (S(1).type == "()" && length(S) == 2)
                x = S(1).subs{:};
                seg = neuron.Segment(self, x);
                seg.(S(2).subs) = varargin{:};
            else
                error("Section.%s not found.", string(S(1).subs));
            end
        end

        function varargout = subsref(self, S)
        % Implement indexing, returning a Segment.

            % S(1).subs is method (or property) name;
            % S(2).subs is a cell array containing arguments.

            % Check if section has been deleted.
            try
                if ~neuron_api('nrn_section_is_active', self.sec)
                    error();
                end
            catch
                error("Section has been deleted.");
            end

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
            [varargout{1:nargout}] = neuron.chained_method(varargout, S, n_processed);
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
                neuron_api('nrn_mechanism_insert', self.sec, mech_name);
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
                nrnref = neuron.NrnRef(neuron_api('nrn_rangevar_nrnref', self.sec, rangevar, loc));
                % neuron_api('nrn_rangevar_push', self.sec, rangevar, loc);
                % range_ref = neuron.stack.hoc_pop('ref');
                % nrnref = neuron.NrnRef(neuron_api('nrn_get_ref', range_ref, 1));
            else
                warning("Range variable '"+rangevar+"' not found.");
                disp("Available range variables:")
                for i=1:numel(self.range_list)
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
            neuron_api('nrn_section_connect', self.sec, loc, parent_sec.sec, parent_loc);
        end

        function push(self)
        % Push self to Section stack.
        %   push()
            neuron_api('nrn_section_push', self.sec);
        end

        function addpoint(self, x, y, z, diam)
        % Add point to Section.
        %   addpoint(x, y, z, diam)            
            self.push();
            neuron_api('nrn_double_push', x);
            neuron_api('nrn_double_push', y);
            neuron_api('nrn_double_push', z);
            neuron_api('nrn_double_push', diam);
            neuron_api('nrn_function_call', 'pt3dadd', 4);
            neuron.stack.hoc_pop('double'); % Since nrn_function_call leaves rvalue on stack
            neuron.stack.pop_sections(1);
        end
        function set.L(self, val)
        % Set length of Section.
            neuron_api('nrn_section_length_set', self.sec, val);
        end
        function value = get.L(self)
        % Get length of Section.
            value = neuron_api('nrn_section_length_get', self.sec);
        end
        function value = get.name(self)
        % Get Section name.
            value = neuron_api('nrn_secname', self.sec);
        end
        function self = set.nseg(self, val)
        % Set the number of segments in the Section.
            neuron_api('nrn_nseg_set', self.sec, val);
        end
        function value = get.nseg(self)
        % Get the number of segments in the Section.
            value = neuron_api('nrn_nseg_get', self.sec);
        end
        function self = set.Ra(self, val)
        % Set axial resistance of Section.
            neuron_api('nrn_section_Ra_set', self.sec, val);
        end
        function value = get.Ra(self)
        % Get axial resistance of Section.
            value = neuron_api('nrn_section_Ra_get', self.sec);
        end
        function self = set.rallbranch(self, val)
        % Set rallbranch property of Section.
            neuron_api('nrn_section_rallbranch_set', self.sec, val);
        end
        function value = get.rallbranch(self)
        % Get rallbranch property of Section.
            value = neuron_api('nrn_section_rallbranch_get', self.sec);
        end
        function self = set.diam(self, val)
        % Set diameter of Section.
        %   set_diameter(val)
            neuron_api('nrn_section_diam_set', self.sec, val);
        end
        function value = get.diam(self)
        % Set diameter of Section.
        %   set_diameter(val)
            value = neuron_api('nrn_section_diam_get', self.sec);
        end
        
        function psection(self)
        % Print psection info
        %   psection()
            neuron_api('nrn_section_push', self.sec);
            neuron_api('nrn_function_call', 'psection', 0);
            neuron_api('nrn_section_pop');
        end
        function n3d = n3d(self)
        % Get number of 3D points in Section.
        %   n3d = n3d()
            neuron_api('nrn_section_push', self.sec);
            neuron_api('nrn_function_call', 'n3d', 0);
            n3d = neuron.stack.hoc_pop('double');
            neuron_api('nrn_section_pop');
        end
        function val = x3d(self, idx)
        % Get x3d value at index idx (0-based).
            neuron_api('nrn_section_push', self.sec);
            neuron.stack.push_args(idx);
            neuron_api('nrn_function_call', 'x3d', 1);
            val = neuron.stack.hoc_pop('double');
            neuron_api('nrn_section_pop');
        end

        function val = y3d(self, idx)
        % Get y3d value at index idx (0-based).
            neuron_api('nrn_section_push', self.sec);
            neuron.stack.push_args(idx);
            neuron_api('nrn_function_call', 'y3d', 1);
            val = neuron.stack.hoc_pop('double');
            neuron_api('nrn_section_pop');
        end

        function val = z3d(self, idx)
        % Get z3d value at index idx (0-based).
            neuron_api('nrn_section_push', self.sec);
            neuron.stack.push_args(idx);
            neuron_api('nrn_function_call', 'z3d', 1);
            val = neuron.stack.hoc_pop('double');
            neuron_api('nrn_section_pop');
        end

        function val = arc3d(self, idx)
        % Get arc3d value at index idx (0-based).
            neuron_api('nrn_section_push', self.sec);
            neuron.stack.push_args(idx);
            neuron_api('nrn_function_call', 'arc3d', 1);
            val = neuron.stack.hoc_pop('double');
            neuron_api('nrn_section_pop');
        end

        function val = diam3d(self, idx)
        % Get diam3d value at index idx (0-based).
            neuron_api('nrn_section_push', self.sec);
            neuron.stack.push_args(idx);
            neuron_api('nrn_function_call', 'diam3d', 1);
            val = neuron.stack.hoc_pop('double');
            neuron_api('nrn_section_pop');
        end
        function pt3d = get_pt3d(self)
        % Get all 3D point information; returns a 5xN matrix for N 3D
        % points, with rows [x, y, z, arc, d].
        %   pt3d = get_pt3d()
            neuron_api('nrn_section_push', self.sec);
            neuron_api('nrn_function_call', 'n3d', 0);
            n3d = neuron.stack.hoc_pop('double');
            pt3d = zeros(5, n3d);

            fields = {'x3d', 'y3d', 'z3d', 'arc3d', 'diam3d'};
            for i = 0:(n3d - 1)
                for j = 1:numel(fields)
                    neuron.stack.push_args(i);
                    neuron_api('nrn_function_call', fields{j}, 1);
                    pt3d(j, i + 1) = neuron.stack.hoc_pop('double');
                end
            end
            neuron_api('nrn_section_pop');
        end
        function info(self)
        % Print section info
        %   info()
            
            neuron_api('nrn_section_push', self.sec);
            neuron_api('nrn_function_call', 'n3d', 0);
            npt3d = neuron.stack.hoc_pop('double');
            disp(self.name + " has length " + self.L + ".");
            disp(self.name + " has " + npt3d + " pt3d and " ...
                + self.nseg + " segment(s).");
            for i=1:npt3d
                pt3d = self.get_pt3d();
                disp(pt3d(:, i));
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
