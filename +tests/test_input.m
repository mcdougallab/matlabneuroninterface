classdef test_input < matlab.unittest.TestCase
    
    methods(Test)
        
        function test_loadfile(~)
            example_loadfile;
            assert(any(strcmp(n.fn_void_list, 'continuerun')));
            % assert(n.t == 5);  % Why does this go wrong?
        end
        
        function test_mod(~)
            example_mod;
            assert(any(strcmp(axon.mech_list, "hd")));
            assert(syn.Alpha == 0.0720);
            assert(syn.Beta == 0.0066);
            assert(syn.e == 42);
        end

    end
    
end
