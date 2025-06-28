classdef test_Session < matlab.unittest.TestCase
    methods (Test)
        function testLaunchSingleton(testCase)
            n1 = neuron.launch();
            n2 = neuron.launch();
            testCase.verifyEqual(n1, n2, 'Session should be singleton');
        end

        function testDynamicProps(testCase)
            n = neuron.launch();
            n.fill_dynamic_props();
            testCase.verifyNotEmpty(n.var_list);
            testCase.verifyNotEmpty(n.fn_double_list);
            testCase.verifyNotEmpty(n.fn_void_list);
            testCase.verifyNotEmpty(n.object_list);
        end

        function testDynamicVariableAccess(testCase)
            n = neuron.launch();
            % t and dt are standard NEURON variables
            t = n.t;
            dt = n.dt;
            testCase.verifyClass(t, 'double');
            testCase.verifyClass(dt, 'double');
            n.dt = 0.05;
            testCase.verifyEqual(n.dt, 0.05, 'AbsTol', 1e-12);
        end

        function testDynamicFunctionCall(testCase)
            n = neuron.launch();
            % abs is a standard NEURON function
            result = n.abs(-5);
            testCase.verifyEqual(result, 5);
        end

        function testDynamicObjectCreation(testCase)
            n = neuron.launch();
            v = n.Vector();
            testCase.verifyClass(v, 'neuron.Vector');
        end

        function testAllsecAndSection(testCase)
            n = neuron.launch();
            n.reset_sections();
            n('create soma');
            s = n.Section('soma');
            testCase.verifyClass(s, 'neuron.Section');
            allsecs = n.allsec();
            testCase.verifyGreaterThanOrEqual(numel(allsecs), 1);
            testCase.verifyClass(allsecs{1}, 'neuron.Section');
        end

        function testSectionList(testCase)
            n = neuron.launch();
            n.reset_sections();
            n('create soma, dend');
            soma = n.Section('soma');
            dend = n.Section('dend');
            sl = n.SectionList();
            sl.append(soma);
            sl.append(dend);
            secs = n.allsec(sl);
            testCase.verifyEqual(numel(secs), 2);
            testCase.verifyClass(secs{1}, 'neuron.Section');
        end

        function testResetSections(testCase)
            n = neuron.launch();
            n('create soma');
            n.reset_sections();
            allsecs = n.allsec();
            testCase.verifyEmpty(allsecs);
        end

        function testErrorOnInvalidFunction(testCase)
            n = neuron.launch();
            testCase.verifyError(@() n.notafunction(), 'MATLAB:UndefinedFunction');
        end

        function testListFunctions(testCase)
            n = neuron.launch();
            testCase.verifyWarningFree(@() n.list_functions());
        end
    end
end