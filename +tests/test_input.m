classdef test_input < matlab.unittest.TestCase

    properties
        tol = 1e-10;
    end
    
    methods(Test)
        
        function test_loadfile(testCase)
            example_loadfile;
            testCase.verifyTrue(any(strcmp(n.fn_void_list, 'continuerun')));
            testCase.verifyEqual(n.t, 5, "RelTol", testCase.tol);
        end
        
        function test_mod(testCase)
            example_mod;
            testCase.verifyTrue(any(strcmp(axon.mech_list, "hd")));
            testCase.verifyEqual(syn.Alpha, 0.0720, "RelTol", testCase.tol);
            testCase.verifyEqual(syn.Beta, 0.0066, "RelTol", testCase.tol);
            testCase.verifyEqual(syn.e, 42, "RelTol", testCase.tol);
        end

    end
    
end
