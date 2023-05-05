classdef test_input < matlab.unittest.TestCase

    properties
        tol = 1e-4;
    end
    
    methods(Test)
        
        function test_loadfile(test)
            example_loadfile;
            assert(any(strcmp(n.fn_void_list, 'continuerun')));
            assert(abs(n.t - 5) < test.tol);
        end
        
        function test_mod(test)
            example_mod;
            assert(any(strcmp(axon.mech_list, "hd")));
            assert(abs(syn.Alpha - 0.0720) < test.tol);
            assert(abs(syn.Beta - 0.0066) < test.tol);
            assert(abs(syn.e - 42) < test.tol);
        end

    end
    
end
