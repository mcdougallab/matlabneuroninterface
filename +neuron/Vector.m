classdef Vector < neuron.Object
% Vector Class for recording quantities such as time and voltage.
    
    properties (SetAccess=protected, GetAccess=public)
        apply_func_list   % List of allowed built-in functions.
    end

    methods

        function self = Vector(obj)
        % Initialize Vector
        %   Vector(obj) constructs a Matlab wrapper for a NEURON vector
        %   (obj).
            self = self@neuron.Object(obj);

            self.apply_func_list = [];
            arr = split(neuron_api('get_nrn_functions'), ";");
            arr = arr(1:end-1);

            % Add dynamic mechanisms and range variables.
            % See: doc/DEV_README.md#neuron-types
            for i=1:length(arr)
                var = split(arr(i), ":");
                if (var(2) == "264")
                    self.apply_func_list = [self.apply_func_list var(1)];
                end
            end

        end

        % See https://nl.mathworks.com/help/matlab/matlab_oop/code-patterns-for-subsref-and-subsasgn-methods.html
        function self = subsasgn(self, S, varargin)
            % Assigning a Vector element by index.
            if (length(S) == 1 && S(1).type == "()")
                element_id = S(1).subs{:};
                self.call_method_hoc('set', 'Object', element_id-1, varargin{:});
            % Are we trying to directly access a class property?
            elseif (isa(S(1).subs, "char") && length(S) == 1 && isprop(self, S(1).subs))
                if any(strcmp(S(1).subs, {'obj', 'objtype', 'attr_list', 'attr_array_map', ...
                                          'mt_double_list', 'mt_object_list', 'mt_string_list'}))
                    error("Property '%s' is read-only and cannot be set after construction.", S(1).subs);
                end
                self.(S(1).subs) = varargin{:};
            else
                self = subsasgn@neuron.Object(self, S, varargin{:});
            end
        end

        function varargout = subsref(self, S)
            % Are we trying to access a Vector element?
            if (length(S) == 1 && S(1).type == "()")
                element_id = S(1).subs{:};
                if self.length() > 0
                    [varargout{1:nargout}] = self.data(element_id);
                else
                    error("Trying to access element of empty Vector.")
                end
            else
                % Adjust for 0-based indexing where applicable.
                if (S(1).subs == "at" || ...
                    S(1).subs == "remove" || ...
                    S(1).subs == "min_ind" || ...
                    S(1).subs == "max_ind" || ...
                    S(1).subs == "sum" || ...
                    S(1).subs == "sumsq" || ...
                    S(1).subs == "mean" || ...
                    S(1).subs == "var" || ...
                    S(1).subs == "stdev" || ...
                    S(1).subs == "c" || ...
                    S(1).subs == "cl")
                    % Subtract 1 from each index in S(1).subs
                    for i = 1:numel(S(2).subs)
                        S(2).subs{i} = S(2).subs{i} - 1;
                    end
                end
                if (S(1).subs == "get" || ...
                    S(1).subs == "set" || ...
                    S(1).subs == "insrt")
                    if ~isempty(S(2).subs)
                        S(2).subs{1} = S(2).subs{1} - 1;
                    end
                end
                if (S(1).subs == "fwrite" || ...
                    S(1).subs == "apply" || ...
                    S(1).subs == "addrand" || ...
                    S(1).subs == "setrand")
                    if numel(S(2).subs) > 1
                        for i = 2:numel(S(2).subs)
                            S(2).subs{i} = S(2).subs{i} - 1;
                        end
                    end
                end
                if (S(1).subs == "printf")
                    for i = 1:numel(S(2).subs)
                        if isnumeric(S(2).subs{i})
                            S(2).subs{i} = S(2).subs{i} - 1;
                        end
                    end
                end
                if (S(1).subs == "indwhere" || ...
                    S(1).subs == "indvwhere")
                    [varargout{1:nargout}] = subsref@neuron.Object(self, S);
                    if ~isempty(varargout) && isnumeric(varargout{1}) && varargout{1} ~= -1
                        varargout{1} = varargout{1} + 1;
                    end
                    return
                end
                if (S(1).subs == "sortindex")
                    [varargout{1:nargout}] = subsref@neuron.Object(self, S);
                    call_method_hoc(varargout{1:nargout}, 'add', 'Object', 1);
                    return
                end
                if (S(1).subs == "smhist")
                    if numel(S(2).subs) >= 2
                        S(2).subs{2} = S(2).subs{2} - 1;
                    end
                end
                if (S(1).subs == "index")
                    if numel(S(2).subs) == 2 && isa(S(2).subs{2}, "neuron.Vector")
                        call_method_hoc(S(2).subs{2}, 'sub', 'Object', 1);
                    end
                end
                if (S(1).subs == "copy")
                    nsubs = numel(S(2).subs);
                    undo_add = [];  % Keep track of which vectors we modified
                    if nsubs == 2 && isa(S(2).subs{2}, "neuron.Vector")
                        call_method_hoc(S(2).subs{2}, 'sub', 'Object', 1);
                        undo_add = [undo_add, 2];
                    elseif nsubs == 3 && isa(S(2).subs{2}, "neuron.Vector") && isa(S(2).subs{3}, "neuron.Vector")
                        call_method_hoc(S(2).subs{2}, 'sub', 'Object', 1);
                        call_method_hoc(S(2).subs{3}, 'sub', 'Object', 1);
                        undo_add = [undo_add, 2, 3];
                    else
                        for i = 2:nsubs
                            if isnumeric(S(2).subs{i})
                                S(2).subs{i} = S(2).subs{i} - 1;
                            end
                        end
                    end
                    % Call the method
                    [varargout{1:nargout}] = subsref@neuron.Object(self, S);
                    % Restore vectors to 1-based indexing
                    for idx = undo_add
                        call_method_hoc(S(2).subs{idx}, 'add', 'Object', 1);
                    end
                    return
                end
                if (S(1).subs == "play")
                    nsubs = numel(S(2).subs);
                    undo_add = [];  % Track vectors to re-add if subtracted

                    % Case: play(index)
                    if nsubs == 1 && isnumeric(S(2).subs{1})
                        S(2).subs{1} = S(2).subs{1} - 1;
                        index_was_numeric = true;
                    else
                        index_was_numeric = false;
                    end

                    % Case: play(..., indices_of_discontinuities_vector)
                    % or play(..., tvec, indices_vector)
                    if nsubs >= 3 && isa(S(2).subs{3}, "neuron.Vector")
                        call_method_hoc(S(2).subs{3}, 'sub', 'Object', 1);
                        undo_add = [undo_add, 3];
                    end

                    % Call the actual play method
                    [varargout{1:nargout}] = subsref@neuron.Object(self, S);

                    % Restore anything modified
                    for idx = undo_add
                        call_method_hoc(S(2).subs{idx}, 'add', 'Object', 1);
                    end
                    if index_was_numeric
                        varargout{1} = varargout{1};  % Optional: no return value typically, but restores clarity
                    end
                    return
                end
                [varargout{1:nargout}] = subsref@neuron.Object(self, S);
                % Restore input vector values where applicable, i.e., readd subtracted 1
                if (S(1).subs == "index")
                    if numel(S(2).subs) == 2 && isa(S(2).subs{2}, "neuron.Vector")
                        call_method_hoc(S(2).subs{2}, 'add', 'Object', 1);
                    end
                end
            end
        end

        function nrnref = ref(self, varargin)
        % Get reference to vector data or a specific index.
        %   nrnref = ref()           % reference to entire vector
        %   nrnref = ref(index)      % reference to specific index
            if nargin == 1
                nrnref = neuron.NrnRef(neuron_api('nrn_vector_nrnref', self.obj, self.length(), 0));
            elseif nargin == 2
                index = varargin{1};
                nrnref = neuron.NrnRef(neuron_api('nrn_vector_nrnref', self.obj, self.length(), index-1));
            else
                error('Invalid number of arguments to ref().');
            end
        end

        function vec = get_vec(self)
        % Access C++ Vector object.
        %   vec = get_vec()
            vec = self.obj;
        end

        function arr = data(self, index)
        % Access Vector data.
        %   arr = data()
        %   element = data(index)
            arr = neuron_api('nrn_vector_data', self.obj, self.length());
            
            if nargin == 2
                arr = arr(index);
            end
        end
        
        function value = length(self)
        % Get Vector data length.
        %   value = length()
            value = self.call_method_hoc('size', 'double');
        end
        
        function value = size(self)
        % Get Vector size.
        %   value = size()
            value = [1 self.length()];
        end

        function ind = end(self, k, n)
        % Get Vector end.
        %   value = v(end);
            sz = self.size();
            if k < n
                ind = sz(k);
            else
                ind = prod(sz(k:end));
            end
        end

        function arr = double(self, index)
        % Access Vector data as Matlab doubles.
        %   arr = double()
        %   element = double(index)
            if nargin == 2
                arr = double(self.data(index));
            else
                if self.length() > 0
                    arr = double(self.data());
                else
                    arr = zeros(1, 0);
                end
            end
        end

        function value = max(self)
            value = self.call_method_hoc('max', 'double');
        end

        function value = min(self)
            value = self.call_method_hoc('min', 'double');
        end

        function value = apply(self, varargin)
        % Apply built-in function to vector.
        %   value = apply(varargin)
            if length(varargin) ~= 1
                warning("Vector.apply() always takes a single argument.");
            elseif any(strcmp(self.apply_func_list, varargin{1}))
                value = call_method_hoc(self, "apply", "Object", varargin{1});
            else
                warning("Built-in function '"+varargin{1}+"' not found.");
                disp("Available built-in functions:")
                disp(self.apply_func_list);
                for i = 1:numel(self.apply_func_list)
                    disp("    "+self.apply_func_list(i));
                end
            end
            
        end

    end
end
