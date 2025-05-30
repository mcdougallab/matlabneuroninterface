classdef test_Vector < matlab.unittest.TestCase
    methods (Test)
        function testConstructor(testCase)
            % Create a NEURON Vector via NEURON API or session
            n = neuron.launch();
            v = n.Vector();
            testCase.verifyClass(v, 'neuron.Vector');
        end

        function testLengthAndSize(testCase)
            n = neuron.launch();
            v = n.Vector();
            v.append(1); v.append(2); v.append(3);
            testCase.verifyEqual(v.length(), 3);
            testCase.verifyEqual(v.size(), [1 3]);
        end

        function testIndexing(testCase)
            n = neuron.launch();
            v = n.Vector();
            v.append(10); v.append(20); v.append(30);
            testCase.verifyEqual(v(1), 10);
            testCase.verifyEqual(v(2), 20);
            testCase.verifyEqual(v(3), 30);
        end

        function testAssignment(testCase)
            n = neuron.launch();
            v = n.Vector();
            v.append(1); v.append(2); v.append(3);
            v(2) = 99;
            testCase.verifyEqual(v(2), 99);
        end

        function testDoubleConversion(testCase)
            n = neuron.launch();
            v = n.Vector();
            v.append(1.1); v.append(2.2); v.append(3.3);
            arr = double(v);
            testCase.verifyEqual(arr, [1.1 2.2 3.3], 'AbsTol', 1e-12);
        end

        function testApplyFunction(testCase)
            n = neuron.launch();
            v = n.Vector();
            v.append(1); v.append(2); v.append(3);
            if any(strcmp(v.apply_func_list, "sum"))
                s = v.apply("sum");
                testCase.verifyEqual(s, 6);
            end
        end

        function testEmptyVector(testCase)
            n = neuron.launch();
            v = n.Vector();
            testCase.verifyEqual(v.length(), 0);
            testCase.verifyEqual(double(v), zeros(1,0));
            testCase.verifyError(@() v(1), 'MATLAB:badsubscript');
        end

        function testOutOfBoundsIndex(testCase)
            n = neuron.launch();
            v = n.Vector();
            v.append(1);
            testCase.verifyError(@() v(2), 'MATLAB:badsubscript');
        end

        function testInvalidApplyFunction(testCase)
            n = neuron.launch();
            v = n.Vector();
            v.append(1);
            testCase.verifyWarning(@() v.apply('notafunc'), '');
        end

        function testRef(testCase)
            n = neuron.launch();
            v = n.Vector();
            v.append(1);
            ref = v.ref();
            testCase.verifyClass(ref, 'neuron.NrnRef');
        end
    end
end