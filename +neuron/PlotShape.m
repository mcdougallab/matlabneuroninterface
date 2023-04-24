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
        % Plot PlotShape data; make sure to call n.define_shape() before
        % calling this.
        %   plot()

            % Call n.define_shape() first? We don't have the Neuron object,
            % so we have to do:
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
                dx = double(s.length);
                arc3d = pt3d(4, :);

                segments = s.segments();
                for j=1:s.nseg
                    seg = segments{j};
                    [x_lo, x_hi] = seg.get_bounds();
                    x_lo = x_lo * dx;
                    x_hi = x_hi * dx;
                    seg_arc_arr = arc3d(arc3d(:) > x_lo & arc3d(:) < x_hi);
                    seg_arc_arr = [x_lo seg_arc_arr x_hi];
                    seg_x3d_arr = interp1_arr(pt3d(4, :), pt3d(1, :), seg_arc_arr);
                    seg_y3d_arr = interp1_arr(pt3d(4, :), pt3d(2, :), seg_arc_arr);
                    seg_z3d_arr = interp1_arr(pt3d(4, :), pt3d(3, :), seg_arc_arr);
                    seg_d3d_arr = interp1_arr(pt3d(4, :), pt3d(5, :), seg_arc_arr);

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
