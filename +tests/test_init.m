classdef test_init < matlab.unittest.TestCase
    
    methods(Test)
        % Test methods
        
        function test_neuron_initialization(testCase)
            % Initialize Neuron.
            n = neuron.start_session();
            % Check Neuron interface object.
            testCase.verifyClass(n, "neuron.Session");
            testCase.verifyTrue(isprop(n, 't'));
        end

    end
    
end
