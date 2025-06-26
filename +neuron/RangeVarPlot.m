classdef RangeVarPlot < neuron.Object
% RangeVarPlot Class for making plots of range variables.

    methods

        function self = RangeVarPlot(obj)
        % Initialize RangeVarPlot
        %   RangeVarPlot(obj) constructs a Matlab wrapper for a Neuron
        %   RangeVarPlot.
            if ~isa(obj, 'uint64') || ~isreal(obj) || numel(obj) ~= 1
                error('Invalid input for RangeVarPlot constructor.');
            end
            self = self@neuron.Object(obj);
        end

        function self = subsasgn(self, S, varargin)
        % Assigning a PlotShape element by index.
            if (isa(S(1).subs, "char") && length(S) == 1 && isprop(self, S(1).subs))
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
            [varargout{1:nargout}] = subsref@neuron.Object(self, S);
        end

        function [x, y] = get_xy_data(self)
        % Get x, y data to plot.
        %   [x, y] = get_xy_data()
            x = neuron.Session.hoc_new_obj('Vector');
            y = neuron.Session.hoc_new_obj('Vector');
            self.call_method_hoc('to_vector', 'double', y, x);
        end

        function plot(self, varargin)
        % Plot RangeVarPlot data.
        %   plot()
            [x, y] = self.get_xy_data();
            plot(x.data(), y.data(), varargin{:});
        end

    end
end
