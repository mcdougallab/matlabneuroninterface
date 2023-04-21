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
            % TODO:
            % - Interpolate 3D points (see
            %   https://github.com/neuronsimulator/nrn/blob/master/share/lib/python/neuron/__init__.py,
            %   line 1134 "def _get_3d_pt(segment):").
            % - Use spi.varname() to select the right var to plot at
            %   each Segment.
            % - Make a 3D plot of spi.varname() at each Segment  
            %   location, with lower bound spi_some.low() and upper 
            %   bound spi_some.high(); also include all 3D points.
            spi = clib.neuron.get_plotshape_interface(self.obj);
            disp("PlotShape, plotting " + spi.varname() + " from " + ...
                 spi.low() + " to " + spi.high())
            sl = spi.neuron_section_list();
            secs = neuron.allsec(sl);
            for i=1:numel(secs)
                s = secs{i};
                disp("- Section " + s.name);

                % Get all 3D point information.
                npt3d = s.get_sec().npt3d;
                for j=1:npt3d
                    pt = s.get_sec().pt3d(j);
                    disp("  - pt3d {x: " + pt.x + ", y: " + pt.y + ...
                         ", z: " + pt.z + ", d: " + pt.d + "}");
                end

                % Get all segment information.
                segments = s.segments();
                for j=1:s.nseg
                    seg = segments{j};
                    var = spi.varname();
                    disp("  - segment x: " + seg.x + ...
                         ", " + var + ": " + s.ref(var, seg.x).get());
                end

            end
        end

    end
end