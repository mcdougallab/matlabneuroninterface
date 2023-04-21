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

            % Call n.define_shape() first? 
            % sym = clib.neuron.hoc_lookup("define_shape");
            % clib.neuron.hoc_call_func(sym, 0);

            spi = clib.neuron.get_plotshape_interface(self.obj);
            disp("PlotShape, plotting " + spi.varname() + " from " + ...
                 spi.low() + " to " + spi.high());
            sl = spi.neuron_section_list();
            secs = neuron.allsec(sl);
            for i=1:numel(secs)
                s = secs{i};
                disp("- Section " + s.name);

                % Get all 3D point information.
                pt3d = s.get_pt3d();
                for j=1:s.get_sec().npt3d
                    disp("  - pt3d [x, y, z, arc, d]: " + ...
                         pt3d(1, j) + ", " + ...
                         pt3d(2, j) + ", " + ...
                         pt3d(3, j) + ", " + ...
                         pt3d(4, j) + ", " + ...
                         pt3d(5, j) + "]");
                end

                % Interpolate to get segment 3d point.
                segments = s.segments(true);
                for j=1:numel(segments)
                    seg = segments{j};
                    seg_l = seg.x * s.length;
                    seg_x3d = interp1(pt3d(4, :), pt3d(1, :), seg_l);
                    seg_y3d = interp1(pt3d(4, :), pt3d(2, :), seg_l);
                    seg_z3d = interp1(pt3d(4, :), pt3d(3, :), seg_l);

                    var = spi.varname();
                    disp("  - segment x: " + seg.x + ", " + ...
                         var + ": " + s.ref(var, seg.x).get() + ", " + ...
                         "[x, y, z]: [" + seg_x3d + ", " + seg_y3d + ", " + seg_z3d + "]");
                end

            end
        end

    end
end