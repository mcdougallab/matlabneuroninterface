classdef RangeVarPlot < neuron.Object
% RangeVarPlot Class for making plots of range variables.

    methods

        function self = RangeVarPlot(obj)
        % Initialize RangeVarPlot
        %   RangeVarPlot(obj) constructs a Matlab wrapper for a Neuron
        %   RangeVarPlot.
            self = self@neuron.Object(obj);
        end

        function [x, y] = get_xy_data(self)
        % Get x, y data to plot.
        %   [x, y] = get_xy_data()
            x = neuron.Neuron.hoc_new_obj("Vector");
            y = neuron.Neuron.hoc_new_obj("Vector");
            self.call_method_hoc("to_vector", "double", y, x);
        end

        function plot(self, varargin)
        % Plot RangeVarPlot data.
        %   plot()
            [x, y] = self.get_xy_data();
            plot(x, y, varargin{:});
        end

    end
end
