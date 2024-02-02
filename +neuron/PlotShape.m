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
        % Get PlotShape data; a table with data to plot.
        %   data = get_plot_data()

            % Call n.define_shape() first
            neuron.Session.call_func_hoc("define_shape", "double");

            spi = clib.neuron.get_plotshape_interface(self.obj);

            section_plot_data = double(clib.neuron.get_plot_data(spi));
            section_plot_data = transpose(reshape(section_plot_data, 9, []));

            x = [section_plot_data(:, 1) section_plot_data(:, 2)];
            y = [section_plot_data(:, 3) section_plot_data(:, 4)];
            z = [section_plot_data(:, 5) section_plot_data(:, 6)];
            d = (section_plot_data(:, 7) + section_plot_data(:, 8)) / 2;
            v = section_plot_data(:, 9);
            data = table(x, y, z, d, v, 'VariableNames', {'x', 'y', 'z', 'line_width', 'color'}); 

            % Normalize color value
            data.color = data.color - spi.low();
            data.color = data.color / (spi.high() - spi.low());
            data.color = min(max(data.color, 0), 1);
        end

        function plot(self, cmap)
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
            cellData = {};
            for i=1:size(data, 1)
                seg = data(i, :);
                cellData{end+1} = seg.x;
                cellData{end+1} = seg.y;
                cellData{end+1} = seg.z;
            end

            if nargin < 2
                cmap = colormap;
            end
            values = table2array(data(:, 'color'));
            indices = round(interp1(linspace(0, 1, length(cmap)), 1:length(cmap), values, 'linear', 'extrap'));

            l = plot3(cellData{:});

            for i=1:size(data, 1)
                seg = data(i, :);
                l(i).Color = cmap(indices(i), :);
                l(i).LineWidth = seg.line_width;
            end

            % Equal aspect ratio for x,y,z.
            set(gca, 'DataAspectRatio', [1 1 1])
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
