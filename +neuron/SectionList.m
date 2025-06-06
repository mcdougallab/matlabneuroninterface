classdef SectionList < neuron.Object
    properties (SetAccess=protected, GetAccess=public)
        Sections
    end

    methods
        function self = SectionList(obj, varargin)
            % Constructor: accepts a cell array or vector of sections
            self = self@neuron.Object(obj);
            self.Sections = {};
            for i = 1:numel(varargin)
                self.call_method_hoc('append', 'double', varargin{i});
            end
            
        end

        function arr = data(self, index)
        % Access Vector data.
        %   arr = data()
        %   element = data(index)
            arr1 = neuron_api('nrn_sectionlist_data', self.obj);
            arr = neuron.Section(arr1);
            
            if nargin == 2
                arr1 = arr(index);
                arr = neuron.Section(arr1);
            end
        end

        function varargout = subsref(self, S)
            % Are we trying to access a Vector element?
            if (length(S) == 1 && S(1).type == "()")
                element_id = S(1).subs{:};
                if numel(self.Sections) > 0
                    [varargout{1:nargout}] = self.data(element_id);
                else
                    error("Trying to access element of empty Vector.")
                end
            else
                [varargout{1:nargout}] = subsref@neuron.Object(self, S);
            end
        end

        function it = getIterator(obj)
            % Returns an iterator object for use in for-loops
            it = neuron.SectionListIterator(obj);
        end

        % Enable for-loop iteration: MATLAB calls this when you do "for x = obj"
        function it = iter(obj)
            it = obj.getIterator();
        end
    end
end

% Overload subsref to support for-loop iteration in MATLAB R2019b and later
function it = subsref(obj, S)
    if strcmp(S(1).type, '()') && numel(S) == 1
        it = obj.getIterator();
    else
        it = builtin('subsref', obj, S);
    end
end