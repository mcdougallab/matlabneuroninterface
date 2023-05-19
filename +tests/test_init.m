classdef test_init < matlab.unittest.TestCase
    
    methods(Test)
        % Test methods
        
        function test_neuron_initialization(testCase)
            % Initialize Neuron.
            n = neuron.Neuron();
            % Check Neuron interface object.
            testCase.verifyClass(n, "neuron.Neuron");
            testCase.verifyTrue(isprop(n, 't'));
        end

    end
    
end
