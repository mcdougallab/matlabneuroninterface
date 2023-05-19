classdef test_morphology < matlab.unittest.TestCase

    properties
        tol = 1e-10;
    end
    
    methods(Test)
        % Test methods
        
        function test_allsec(testCase)
            % Call the function to test
            example_allsec;
            % Check output.
            testCase.verifyClass(sl, "neuron.Object");
            testCase.verifyEqual(sl.objtype, "SectionList");
            testCase.verifyClass(axon2_new, "neuron.Section");
            testCase.verifyEqual(axon2_new.name, "axon2");
            testCase.verifyEqual(axon2_new.length, 42);
            testCase.verifyClass(soma_new, "neuron.Section");
            testCase.verifyEqual(soma_new.length, 100);
            testCase.verifyEqual(double(soma_new.nseg), 5);
            testCase.verifyEqual(soma_new.name, "soma");
            testCase.verifyClass(soma_segs{1}, "neuron.Segment");
            testCase.verifyEqual(soma_segs{1}.parent_name, "soma");
            testCase.verifyEqual(numel(soma_segs), double(soma_new.nseg));
        end

        function test_morph(testCase)
            % Call the function to test
            example_morph;
            % Check output.
            testCase.verifyEqual(main.length, 200);
            testCase.verifyEqual(double(main.nseg), 3);
            testCase.verifyEqual(iclamp.dur, 10000);
            testCase.verifyTrue(~exist('branch2', 'var'));
        end
    end
    
end
