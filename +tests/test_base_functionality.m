classdef test_base_functionality < matlab.unittest.TestCase

    properties
        tol = 1e-10;
    end
    
    methods(Test)
        % Test methods
        
        function test_run(testCase)
            example_run;
            testCase.verifyEqual(n.t, 0.025, "RelTol", testCase.tol);
        end
        
        function test_vector(testCase)
            % Example to run.
            example_vector;
            % Asserts for first vector.
            testCase.verifyClass(v, "neuron.Vector");
            testCase.verifyEqual(length(v), 11);
            testCase.verifyEqual(v(2), 0.025, "RelTol", testCase.tol);
            testCase.verifyEqual(v(3), 42, "RelTol", testCase.tol);
            testCase.verifyEqual(v(11), 5, "RelTol", testCase.tol);
            % Asserts for second vector.
            testCase.verifyClass(v2, "neuron.Vector");
            testCase.verifyEqual(v2(2), 1, "RelTol", testCase.tol);
            testCase.verifyEqual(v2(6), 5.3, "RelTol", testCase.tol);
            testCase.verifyEqual(length(v2), 9);
            testCase.verifyEqual(v2_max, 12, "RelTol", testCase.tol);
        end

    end
    
end
