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
        % Plot PlotShape data.
        %   plot()

            % Call n.define_shape() first
            neuron.Neuron.call_func_hoc("define_shape", "double");

            spi = clib.neuron.get_plotshape_interface(self.obj);
            sl = spi.neuron_section_list();
            secs = neuron.allsec(sl);

            figure;
            hold on;
            for i=1:numel(secs)
                s = secs{i};

                % Get all 3D point information.
                pt3d = s.get_pt3d();

                % Get total section length and arc points.
                dx = double(s.length);
                arc3d = pt3d(4, :);

                % Iterate over segments.
                segments = s.segments();
                for j=1:s.nseg
                    % Get start, pt3ds and end point for each segment.
                    seg = segments{j};
                    [x_lo, x_hi] = seg.get_bounds();
                    x_lo = x_lo * dx;
                    x_hi = x_hi * dx;
                    seg_arc_arr = arc3d(arc3d(:) > x_lo & arc3d(:) < x_hi);
                    seg_arc_arr = [x_lo seg_arc_arr x_hi];

                    % Interpolate x,y,z,d for each point in seg_arc_arr.
                    seg_x3d_arr = interp1_arr(pt3d(4, :), pt3d(1, :), seg_arc_arr);
                    seg_y3d_arr = interp1_arr(pt3d(4, :), pt3d(2, :), seg_arc_arr);
                    seg_z3d_arr = interp1_arr(pt3d(4, :), pt3d(3, :), seg_arc_arr);
                    seg_d3d_arr = interp1_arr(pt3d(4, :), pt3d(5, :), seg_arc_arr);

                    % Find value of selected quantity for this segment.
                    var = spi.varname();
                    seg_value = s.ref(var, seg.x).get();
                    seg_value_rel = seg_value - spi.low();
                    seg_value_rel = seg_value_rel  / (spi.high() - spi.low());
                    seg_value_rel = min(max(seg_value_rel, 0), 1);
                    
                    % Plot between pt3ds, one pair at a time.
                    for k=1:numel(seg_arc_arr)-1
                        x = [seg_x3d_arr(k) seg_x3d_arr(k+1)];
                        y = [seg_y3d_arr(k) seg_y3d_arr(k+1)];
                        z = [seg_z3d_arr(k) seg_z3d_arr(k+1)];
                        h = plot3(x, y, z);
                        h.LineWidth = (seg_d3d_arr(k) + seg_d3d_arr(k+1))/2;
                        set(h, 'color', [seg_value_rel, 0, 1-seg_value_rel]);
                    end
                end
            end

            % Equal aspect ration for x,y,z.
            h = get(gca,'DataAspectRatio');
            if h(3)==1
                set(gca,'DataAspectRatio',[1 1 1/max(h(1:2))])
            else
                set(gca,'DataAspectRatio',[1 1 h(3)])
            end
            xlabel('x');
            ylabel('y');
            zlabel('z');
            title('PlotShape: ' + spi.varname());
            view(3);
            hold off;

        end

    end
end

function y_new_arr = interp1_arr(x_arr, y_arr, x_new_arr)
% Linearly interpolate array of values (x_new_arr), based on xy-data pairs
% given by arrays x_arr, y_arr.
    y_new_arr = zeros(1, numel(x_new_arr));
    for i=1:numel(x_new_arr)
        y_new_arr(i) = interp1(x_arr, y_arr, x_new_arr(i));
    end
end
