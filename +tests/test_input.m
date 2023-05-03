classdef test_input < matlab.unittest.TestCase

    properties
        tol = 1e-4;
    end
    
    methods(Test)
        
        function test_loadfile(self)
            example_loadfile;
            assert(any(strcmp(n.fn_void_list, 'continuerun')));
            assert(abs(n.t - 5) < self.tol);
        end
        
        function test_mod(self)
            example_mod;
            assert(any(strcmp(axon.mech_list, "hd")));
            assert(abs(syn.Alpha - 0.0720) < self.tol);
            assert(abs(syn.Beta - 0.0066) < self.tol);
            assert(abs(syn.e - 42) < self.tol);
        end

    end
    
end
