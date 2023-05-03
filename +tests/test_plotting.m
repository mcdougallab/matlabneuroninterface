classdef test_plotting < matlab.unittest.TestCase

    properties
        tol = 1e-4;
    end
    
    methods(Test)
        
        function test_plotshape(~)
            set(0,'DefaultFigureVisible','off');
            example_plotshape;
            plot_data_some = ps_some.get_plot_data();
            assert(plot_data_some{1}.x(2) == 3);
            assert(plot_data_some{end}.line_width == 2);
            plot_data_all = ps_all.get_plot_data();
            assert(plot_data_all{16}.y(2) == 2.5);
            assert(plot_data_all{end}.line_width == 3);
            set(0,'DefaultFigureVisible','on');
        end
        
        function test_rangevarplot(self)
            set(0,'DefaultFigureVisible','off');
            example_rangevarplot;
            [x, y] = rvp.get_xy_data();
            assert(abs(x(2) - 0.0314) < self.tol);
            assert(abs(x(end) - 6.28) < self.tol);
            assert(abs(y(50) - 0.0956) < self.tol);
            set(0,'DefaultFigureVisible','on');
        end

    end
    
end
