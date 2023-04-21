classdef PlotShape < neuron.Object
% PlotShape Class making 3D colorplots.

    methods

        function self = PlotShape(obj)
        % Initialize PlotShape
        %   PlotShape(obj) constructs a Matlab wrapper for a Neuron
        %   PlotShape.
            self = self@neuron.Object("PlotShape", obj);
        end

        function plot(self)
            spi = clib.neuron.get_plotshape_interface(self.obj);
            disp(spi.low());
            disp(spi.high());
            disp(spi.varname());
            sl = spi.neuron_section_list();
            secs = neuron.allsec(sl);
            for i=1:numel(secs)
                disp(secs{i}.name);
                secs{i}.info();
                % TODO:
                % - Interpolate 3D points (see
                %   https://github.com/neuronsimulator/nrn/blob/master/share/lib/python/neuron/__init__.py,
                %   line 1134 "def _get_3d_pt(segment):").
                % - Use spi.varname() to select the right var to plot at
                %   each Segment.
                % - Make a 3D plot of spi.varname() at each Segment  
                %   location, with lower bound spi_some.low() and upper 
                %   bound spi_some.high(); also include all 3D points.
            end
        end

    end
end