classdef test_plotting < matlab.unittest.TestCase

    properties
        tol = 1e-10;
    end
    
    methods(Test)
        
        function test_plotshape(testCase)
            set(0,'DefaultFigureVisible','off');
            example_plotshape;
            plot_data_some = ps_some.get_plot_data();
            testCase.verifyEqual(plot_data_some{1}.x(2), 3);
            testCase.verifyEqual(plot_data_some{end}.line_width, 2);
            plot_data_all = ps_all.get_plot_data();
            testCase.verifyEqual(plot_data_all{16}.y(2), 2.5);
            testCase.verifyEqual(plot_data_all{end}.line_width, 3);
            set(0,'DefaultFigureVisible','on');
        end
        
        function test_rangevarplot(testCase)
            set(0,'DefaultFigureVisible','off');
            example_rangevarplot;
            [x, y] = rvp.get_xy_data();
            testCase.verifyEqual(x(2), 0.0314, "RelTol", testCase.tol);
            testCase.verifyEqual(x(end), 6.28, "RelTol", testCase.tol);
            testCase.verifyEqual(y(50), 0.0956, "RelTol", testCase.tol);
            set(0,'DefaultFigureVisible','on');
        end

    end
    
end
