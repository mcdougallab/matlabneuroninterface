classdef SectionArray
    properties (Access = private)
        sections  % Always a row vector of neuron.Section objects
    end
    
    methods
        function obj = SectionArray(sections)
            % Accepts a cell array or an array of Section objects
            if isempty(sections)
                obj.sections = neuron.Section.empty(1, 0);
            elseif iscell(sections)
                obj.sections = [sections{:}];
            else
                obj.sections = sections;
            end
        end

        function out = subsref(obj, S)
    switch S(1).type
        case '()'

            subs = S(1).subs;

            if numel(obj.sections) == 1
                if numel(subs) == 1 && isequal(subs{1}, 1) || numel(subs) == 2 && isequal(subs{2}, 1)
                    out = obj.sections;
                    return
                else
                    error('Incorrect index for Section Array with 1 section.');
                end
            end

            % Handle 1D indexing: obj(i)
            if numel(subs) == 1
                out = obj.sections(subs{1});

            % Handle 2D indexing: obj(i, j)
            elseif numel(subs) == 2
                rows = subs{1};
                cols = subs{2};
                % Assume row vector layout for obj.sections
                tmp = reshape(obj.sections, 1, []);
                % Handle ':' or specific indices
                out = tmp(rows, cols);

            else
                error('Unsupported number of subscripts.');
            end

            % Forward further indexing if needed
            if length(S) > 1
                out = subsref(out, S(2:end));
            end

        case '.'
            out = builtin('subsref', obj, S);

        otherwise
            error('Unsupported indexing type: %s', S(1).type);
    end
end


        function n = numel(obj)
            n = numel(obj.sections);
        end

        function n = length(obj)
            n = length(obj.sections);
        end

        function varargout = size(obj, dim)
            sz = size(obj.sections);  % true size of internal section array

            if nargin == 1
                % Called as: size(obj) or [a,b] = size(obj)
                if nargout <= 1
                    varargout{1} = sz;
                else
                    % size(obj) with multiple outputs like [a,b] = size(obj)
                    for k = 1:nargout
                        if k <= numel(sz)
                            varargout{k} = sz(k);
                        else
                            varargout{k} = 1;  % pad with 1s
                        end
                    end
                end
            else
                % Called as: size(obj, dim)
                if dim <= numel(sz)
                    varargout{1} = sz(dim);
                else
                    varargout{1} = 1;
                end
            end
        end

        function disp(obj)
            if isempty(obj.sections)
                disp('Empty SectionArray');
            else
                disp(obj.sections);
            end
        end
    end
end