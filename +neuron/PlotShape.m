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
            sl = spi.neuron_section_list();
            secs = neuron.allsec(sl);

            figure;hold on
            for i=1:numel(secs)
                s = secs{i};

                % Get all 3D point information.
                pt3d = s.get_pt3d();

                % Interpolate to get segment 3d locations.
%                 segments = s.segments();
%                 for j=1:numel(segments)
%                     seg = segments{j};
%                     seg_l = seg.x * s.length;
%                     seg_x3d = interp1(pt3d(4, :), pt3d(1, :), seg_l);
%                     seg_y3d = interp1(pt3d(4, :), pt3d(2, :), seg_l);
%                     seg_z3d = interp1(pt3d(4, :), pt3d(3, :), seg_l);
% 
%                     var = spi.varname();
%                     disp("  - segment x: " + seg.x + ", " + ...
%                          var + ": " + s.ref(var, seg.x).get() + ", " + ...
%                          "[x, y, z]: [" + seg_x3d + ", " + seg_y3d + ", " + seg_z3d + "]");
%                 end

                % Get start, pt3ds and end point for each segment.
                dx = double(s.length) / s.nseg;
                arc3d = pt3d(4, :);

                segments = s.segments();
                for j=1:s.nseg
                    seg = segments{j};
                    x_lo = double((j-1) * dx);
                    x_hi = double(j * dx);
                    seg_arc_arr = arc3d(arc3d(:) > x_lo & arc3d(:) < x_hi);
                    seg_arc_arr = [x_lo seg_arc_arr x_hi];
                    seg_x3d_arr = interp1_arr(pt3d(4, :), pt3d(1, :), seg_arc_arr);
                    seg_y3d_arr = interp1_arr(pt3d(4, :), pt3d(2, :), seg_arc_arr);
                    seg_z3d_arr = interp1_arr(pt3d(4, :), pt3d(3, :), seg_arc_arr);
                    % seg_d3d_arr = interp1_arr(pt3d(4, :), pt3d(4, :), seg_arc_arr);

                    var = spi.varname();
                    seg_value = s.ref(var, seg.x).get();
                    seg_value_rel = seg_value - spi.low();
                    seg_value_rel = seg_value_rel  / (spi.high() - spi.low());
                    seg_value_rel = min(max(seg_value_rel, 0), 1);

                    h = plot3(seg_x3d_arr, seg_y3d_arr, seg_z3d_arr);
                    set(h, 'color', [seg_value_rel, 0, 1-seg_value_rel]);
                end
            end
            h = get(gca,'DataAspectRatio');
            if h(3)==1
                set(gca,'DataAspectRatio',[1 1 1/max(h(1:2))])
            else
                set(gca,'DataAspectRatio',[1 1 h(3)])
            end
            xlabel('x');
            ylabel('y');
            zlabel('z');
            title('PlotShape: ' + spi.varname())
            view(3)
        end

    end
end

function arr = interp1_arr(x_arr, v_arr, x_new_arr)
    arr = zeros(1, numel(x_new_arr));
    for i=1:numel(x_new_arr)
        arr(i) = interp1(x_arr, v_arr, x_new_arr(i));
    end
end
