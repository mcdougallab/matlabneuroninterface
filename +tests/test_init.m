classdef test_init < matlab.unittest.TestCase

    properties
        tol = 1e-4;
    end
    
    methods(Test)
        % Test methods
        
        function test_neuron_initialization(self)
            % Initialize Neuron.
            n = neuron.Neuron();
            % Check Neuron interface object.
            assert(isa(n, "neuron.Neuron"));
            assert(isprop(n, 't'));
        end

    end
    
end
