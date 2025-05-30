classdef test_RangeVarPlot < matlab.unittest.TestCase
    methods (Test)
        function testConstructor(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            % Insert a mechanism if needed for a range variable (e.g., 'pas')
            if ~any(strcmp(s.mech_list, 'pas'))
                s.insert_mechanism('pas');
            end
            % Create a RangeVarPlot for 'v'
            rvp = n.RangeVarPlot(s, 'v');
            testCase.verifyClass(rvp, 'neuron.RangeVarPlot');
        end

        function testGetXYData(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            if ~any(strcmp(s.mech_list, 'pas'))
                s.insert_mechanism('pas');
            end
            rvp = n.RangeVarPlot(s, 'v');
            [x, y] = rvp.get_xy_data();
            testCase.verifyClass(x, 'neuron.Vector');
            testCase.verifyClass(y, 'neuron.Vector');
            testCase.verifyGreaterThanOrEqual(x.length(), 1);
            testCase.verifyGreaterThanOrEqual(y.length(), 1);
        end

        function testPlotNoError(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            if ~any(strcmp(s.mech_list, 'pas'))
                s.insert_mechanism('pas');
            end
            rvp = n.RangeVarPlot(s, 'v');
            % Should not error (plot will open a figure)
            testCase.verifyWarningFree(@() rvp.plot());
            close(gcf); % Close the figure after plotting
        end

        function testErrorOnInvalidRangeVar(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            testCase.verifyError(@() n.RangeVarPlot(s, 'notarangevar'), 'MATLAB:expectedError');
        end
    end
end