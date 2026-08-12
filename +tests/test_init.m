classdef test_init < matlab.unittest.TestCase
    
    methods(Test)
        % Test methods
        
        function test_neuron_initialization(testCase)
            % Initialize NEURON.
            n = neuron.launch();
            % Check NEURON interface object.
            testCase.verifyClass(n, "neuron.Session");
            testCase.verifyTrue(isprop(n, 't'));
        end

    end
    
end
