classdef test_base_functionality < matlab.unittest.TestCase

    properties
        tol = 1e-4;
    end
    
    methods(Test)
        % Test methods
        
        function test_run(test)
            example_run;
            assert(abs(n.t - 0.025) < test.tol);
        end
        
        function test_vector(test)
            % Example to run.
            example_vector;
            % Asserts for first vector.
            assert(isa(v, "neuron.Vector"));
            assert(abs(length(v) - 11) < test.tol);
            assert(abs(v(2) - 0.025) < test.tol);
            assert(abs(v(3) - 42) < test.tol);
            assert(abs(v(11) - 5) < test.tol);
            % Asserts for second vector.
            assert(isa(v2, "neuron.Vector"));
            assert(abs(length(v2) - 6) < test.tol);
            assert(abs(v2(2) - 1) < test.tol);
            assert(abs(v2(6) - 5.3) < test.tol);
        end

    end
    
end
