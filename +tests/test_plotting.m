classdef test_plotting < matlab.unittest.TestCase

    properties
        tol = 1e-10;
        tol_large = 1e-6;
    end
    
    methods(Test)
        
        function test_plotshape(testCase)
            set(0,'DefaultFigureVisible','off');
            example_plotshape;
            plot_data_some = ps_some.get_plot_data();
            testCase.verifyEqual(plot_data_some(1, :).x(2), 3);
            testCase.verifyEqual(plot_data_some(end, :).line_width, 2);
            testCase.verifyEqual(size(plot_data_some, 1), 12);
            plot_data_all = ps_all.get_plot_data();
            testCase.verifyEqual(plot_data_all(16, :).y(2), 2.5);
            testCase.verifyEqual(plot_data_all(end, :).line_width, 3);
            testCase.verifyEqual(size(plot_data_all, 1), 18);
            set(0,'DefaultFigureVisible','on');
        end
        
        function test_rangevarplot(testCase)
            set(0,'DefaultFigureVisible','off');
            example_rangevarplot;
            [x, y] = rvp.get_xy_data();
            % RangeVarPlot.to_vector() returns values with ~1e-7 error; not sure why.
            testCase.verifyEqual(x(2), 0.0314, "RelTol", testCase.tol_large);
            testCase.verifyEqual(x(end), 6.28, "RelTol", testCase.tol_large);
            testCase.verifyEqual(y(50), 0.0956462181823123, "RelTol", testCase.tol);
            set(0,'DefaultFigureVisible','on');
        end

    end
    
end
