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
        % Get PlotShape data; a array of structs with data to plot.
        %   data = get_plot_data()

            % Call n.define_shape() first
            neuron.Session.call_func_hoc("define_shape", "double");

            spi = clib.neuron.get_plotshape_interface(self.obj);
            sl = spi.neuron_section_list();
            secs = neuron.Session.allsec(sl);

            data = struct('x', {}, 'y', {}, 'z', {}, 'line_width', {}, 'color', {});
            for i=1:numel(secs)
                s = secs{i};

                section_plot_data = double(clib.neuron.get_section_plot_data(s.sec));
                section_plot_data = transpose(reshape(section_plot_data, 9, []));

                x = [section_plot_data(:, 1) section_plot_data(:, 2)];
                y = [section_plot_data(:, 3) section_plot_data(:, 4)];
                z = [section_plot_data(:, 5) section_plot_data(:, 6)];
                d = (section_plot_data(:, 7) + section_plot_data(:, 8)) / 2;
                v = section_plot_data(:, 9);
                plot_table = table(x, y, z, d, [v, zeros(size(v)), 1-v], 'VariableNames', {'x', 'y', 'z', 'line_width', 'color'}); 
                plot_struct = table2struct(plot_table);
                data = [data; plot_struct];
            end
        end

        function plot(self)
        % Plot PlotShape data.
        %   plot()

            % Get data.
            data = self.get_plot_data();
            spi = clib.neuron.get_plotshape_interface(self.obj);

            % Plot segments between 3d points.
            % TODO: Do one plot3 call instead of in a loop
            %       Can be difficult since each plot3 call needs a seperate line_width and / or color
            figure;
            hold on;
            for i=1:numel(data)
                seg = data(i);
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
