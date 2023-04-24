classdef RangeVarPlot < neuron.Object
% RangeVarPlot Class for making plots of range variables.

    methods

        function self = RangeVarPlot(obj)
        % Initialize RangeVarPlot
        %   RangeVarPlot(obj) constructs a Matlab wrapper for a Neuron
        %   RangeVarPlot.
            self = self@neuron.Object("RangeVarPlot", obj);
        end

        function plot(self)
        % Plot RangeVarPlot data.
        %   plot()
            
            x = neuron.Neuron.hoc_new_obj("Vector");
            y = neuron.Neuron.hoc_new_obj("Vector");
            self.call_method_hoc("to_vector", "double", y, x);
            plot(x, y);
        end

    end
end