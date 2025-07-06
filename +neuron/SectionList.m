classdef SectionList < neuron.Object

    methods
        function self = SectionList(obj, varargin)
            % Constructor: accepts a cell array or vector of sections
            if ~isa(obj, 'uint64') || ~isreal(obj) || numel(obj) ~= 1
                error('Invalid input for SectionList constructor.');
            end
            self = self@neuron.Object(obj);
            for i = 1:numel(varargin)
                self.call_method_hoc('append', 'double', varargin{i});
            end
        end

        function n = numel(self, varargin)
            sections_arr = self.allsec();
            n = numel(sections_arr);
        end

        function varargout = size(self, varargin)
            n = numel(self);
            sz = [1 n];
            if nargout <= 1
                varargout{1} = sz;
            else
                varargout = num2cell(sz);
            end
        end

        function varargout = subsref(self, S)
            if (length(S) == 1 && S(1).type == "()")
                element_id = S(1).subs{:};
                sections_arr = self.allsec();
                if ~isempty(sections_arr)
                    [varargout{1:nargout}] = sections_arr(element_id);
                else
                    error("Trying to access element of empty SectionList.")
                end
            else
                [varargout{1:nargout}] = subsref@neuron.Object(self, S);
            end
        end

        function sections = secs(self)
            sections = self.allsec();
        end

        function all_sections = allsec(self, owner)
        % Return array containing all sections in a NEURON
        % SectionList section_list.
        % Boolean owner (optional, default: false).
        %   allsec(self)
        %   allsec(self, true)

            section_list = neuron_api('nrn_sectionlist_data', self.obj);

            if ~exist('owner', 'var')
                owner = false;
            end

            % Call the MEX function to get section pointers
            section_ptrs = neuron_api('nrn_loop_sections', 1, section_list);

            % Convert section pointers to Section objects
            section_ptrs = section_ptrs(:).';
            n = numel(section_ptrs);
            if n == 0
                all_sections = [];
            else
                all_sections_cell = cell(1, n);
                for i = 1:n
                    all_sections_cell{i} = neuron.Section(section_ptrs(i), owner);
                end
                all_sections = [all_sections_cell{:}];
            end
        end
    end
end
