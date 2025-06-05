classdef PlotShape < neuron.Object
% PlotShape Class making 3D colorplots.

    properties
        index % Unique index for this PlotShape instance
    end

    methods

        function self = PlotShape(obj)
        % Initialize PlotShape
        %   PlotShape(obj) constructs a Matlab wrapper for a Neuron
        %   PlotShape.

            % Call the superclass constructor
            self = self@neuron.Object(obj);

            % Initialize the index
            index = neuron_api('nrn_object_index', self.obj);
            self.index = index;
        end

        function self = subsasgn(self, S, varargin)
        % Assigning a PlotShape element by index.
            if (isa(S(1).subs, "char") && length(S) == 1 && isprop(self, S(1).subs))
                if any(strcmp(S(1).subs, {'obj', 'objtype', 'attr_list', 'attr_array_map', ...
                                          'mt_double_list', 'mt_object_list', 'mt_string_list'}))
                    error("Property '%s' is read-only and cannot be set after construction.", S(1).subs);
                end
                self.(S(1).subs) = varargin{:};
            else
                self = subsasgn@neuron.Object(self, S, varargin{:});
            end
        end

        function varargout = subsref(self, S)
            [varargout{1:nargout}] = subsref@neuron.Object(self, S);
        end

        function data = get_plot_data(self)
        % Get PlotShape data; a table with data to plot.
        %   data = get_plot_data()

            % Call n.define_shape() first
            neuron.Session.call_func_hoc('define_shape', 'double');

            spi = neuron_api('nrn_get_plotshape_interface', self.obj);

            section_plot_data = neuron_api('get_plot_data', spi);
            section_plot_data = transpose(reshape(section_plot_data, 9, []));
            x = [section_plot_data(:, 1) section_plot_data(:, 2)];
            y = [section_plot_data(:, 3) section_plot_data(:, 4)];
            z = [section_plot_data(:, 5) section_plot_data(:, 6)];
            d = (section_plot_data(:, 7) + section_plot_data(:, 8)) / 2;
            v = section_plot_data(:, 9);
            data = table(x, y, z, d, v, 'VariableNames', {'x', 'y', 'z', 'line_width', 'color'}); 

            % Normalize color value
            spi_low = neuron_api('nrn_get_plotshape_low', spi);
            spi_high = neuron_api('nrn_get_plotshape_high', spi);
            data.color = data.color - spi_low;
            data.color = data.color / (spi_high - spi_low);
            data.color = min(max(data.color, 0), 1);
        end

        function plot(self, cmap)
        % Plot PlotShape data.
        % With cmap as the colormap.
        %   plot()

            % Get data.
            data = self.get_plot_data();
            spi = neuron_api('nrn_get_plotshape_interface', self.obj);

            % Plot segments between 3d points.
            figure;
            hold on;
            if nargin < 2
                cmap = colormap;
            end
            values = table2array(data(:, 'color'));
            indices = round(interp1(linspace(0, 1, length(cmap)), 1:length(cmap), values, 'linear', 'extrap'));

            l = plot3(transpose(data.x), transpose(data.y), transpose(data.z));
            varname = neuron_api('nrn_get_plotshape_varname', spi);

            for i=1:size(data, 1)
                seg = data(i, :);
                 if strcmp(varname, 'no variable specified')
                    l(i).Color = [0 0 0]; % Default color if no variable specified
                else
                    l(i).Color = cmap(indices(i), :);
                end
                l(i).LineWidth = seg.line_width;
            end

            % Equal aspect ratio for x,y,z.
            set(gca, 'DataAspectRatio', [1 1 1])
            xlabel('x');
            ylabel('y');
            zlabel('z');
            title(['PlotShape: ', varname]);
            view(3);
            hold off;

        end

        %{
        function var_data = variable(self, var_name)
        % Set specific variable data for the PlotShape.
        %   var_data = variable(var_name)
        %   Example: ps_all.variable('diam')

            var_symbol = neuron_api('nrn_symbol', var_name);
            var_type = neuron_api('nrn_symbol_type', var_symbol);
            
            if var_type ~= 310
            error('The variable "%s" is not valid. Expected var_type 310, but got %d.', var_name, var_type);
            end

            neuron_api('nrn_hoc_call', sprintf('PlotShape[%d].variable("%s")', self.index, var_name));
        end
        %}

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
