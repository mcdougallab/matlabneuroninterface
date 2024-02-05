classdef PlotShape < neuron.Object
% PlotShape Class making 3D colorplots.

    methods

        function self = PlotShape(obj)
        % Initialize PlotShape
        %   PlotShape(obj) constructs a Matlab wrapper for a Neuron
        %   PlotShape.
            self = self@neuron.Object(obj);
        end

        function data = get_plot_data(self)
        % Get PlotShape data; a cell array of structs with data to plot.
        %   data = get_plot_data()

            % Call n.define_shape() first
            neuron.Session.call_func_hoc("define_shape", "double");
            data = {};

            spi = clib.neuron.get_plotshape_interface(self.obj);
            sl = spi.neuron_section_list();
            secs = neuron.Session.allsec(sl);

            for i=1:numel(secs)
                s = secs{i};

                len = s.get_plot_data_length();
                section_plot_data = clib.neuron.get_section_plot_data(s.sec, len);
                section_plot_data = reshape(section_plot_data, [], 9);

                % Plot between pt3ds, one pair at a time.
                for k=1:size(section_plot_data, 1)
                    x = [section_plot_data(k, 1) section_plot_data(k, 2)];
                    y = [section_plot_data(k, 3) section_plot_data(k, 4)];
                    z = [section_plot_data(k, 5) section_plot_data(k, 6)];
                    d = [section_plot_data(k, 7) section_plot_data(k, 8)];
                    v = section_plot_data(k, 9);
                    plot_struct = struct;
                    plot_struct.x = x;
                    plot_struct.y = y;
                    plot_struct.z = z;
                    plot_struct.line_width = mean(d);
                    plot_struct.color = [v, 0, 1-v];
                    data{end+1} = plot_struct;
                end
                % end
            end

        end

        function plot(self)
        % Plot PlotShape data.
        %   plot()

            % Get data.
            data = self.get_plot_data();
            spi = clib.neuron.get_plotshape_interface(self.obj);

            % Plot segments between 3d points.
            figure;
            hold on;
            for i=1:numel(data)
                seg = data{i};
                h = plot3(seg.x, seg.y, seg.z);
                h.LineWidth = seg.line_width;
                set(h, 'color', seg.color);
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
