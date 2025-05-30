classdef test_PlotShape < matlab.unittest.TestCase
    methods (Test)
        function testConstructorAndIndex(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            % Insert a mechanism if needed for a variable (e.g., 'pas')
            if ~any(strcmp(s.mech_list, 'pas'))
                s.insert_mechanism('pas');
            end
            ps = n.PlotShape();
            testCase.verifyClass(ps, 'neuron.PlotShape');
            testCase.verifyGreaterThanOrEqual(ps.index, 0);
        end

        function testGetPlotData(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            if ~any(strcmp(s.mech_list, 'pas'))
                s.insert_mechanism('pas');
            end
            ps = n.PlotShape();
            data = ps.get_plot_data();
            testCase.verifyClass(data, 'table');
            testCase.verifyTrue(all(ismember({'x','y','z','line_width','color'}, data.Properties.VariableNames)));
            testCase.verifyGreaterThanOrEqual(height(data), 1);
        end

        function testPlotNoError(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            if ~any(strcmp(s.mech_list, 'pas'))
                s.insert_mechanism('pas');
            end
            ps = n.PlotShape();
            % Should not error (plot will open a figure)
            testCase.verifyWarningFree(@() ps.plot());
            close(gcf); % Close the figure after plotting
        end

        function testPlotWithCustomColormap(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            if ~any(strcmp(s.mech_list, 'pas'))
                s.insert_mechanism('pas');
            end
            ps = n.PlotShape();
            cmap = jet(32);
            testCase.verifyWarningFree(@() ps.plot(cmap));
            close(gcf);
        end

        function testErrorOnInvalidPlotShape(testCase)
            n = neuron.launch();
            n.reset_sections();
            % No sections created, so PlotShape should fail
            testCase.verifyError(@() n.PlotShape('notavalidobject'), 'MATLAB:expectedError');
        end
    end
end