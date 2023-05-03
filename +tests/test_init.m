classdef test_init < matlab.unittest.TestCase
    
    methods(Test)
        % Test methods
        
        function test_neuron_initialization(~)
            % Initialize Neuron.
            n = neuron.Neuron();
            % Check Neuron interface object.
            assert(isa(n, "neuron.Neuron"));
            assert(isprop(n, 't'));
        end

    end
    
end
