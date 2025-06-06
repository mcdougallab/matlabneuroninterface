% Iterator class (should be in its own file, but can be nested for simplicity)
classdef SectionListIterator
    properties (Access = private)
        List
        Index = 0
    end

    methods
        function obj = SectionListIterator(list)
            obj.List = list;
        end

        function tf = hasNext(obj)
            tf = obj.Index < obj.List.length();
        end

        function sec = next(obj)
            obj.Index = obj.Index + 1;
            sec = obj.List.get(obj.Index);
        end
    end
end