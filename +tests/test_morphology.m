classdef test_morphology < matlab.unittest.TestCase

    properties
        tol = 1e-4;
    end
    
    methods(Test)
        % Test methods
        
        function test_allsec(test)
            % Call the function to test
            example_allsec;
            % Check output.
            assert(isa(sl, "neuron.Object"));
            assert(sl.objtype == "SectionList");
            assert(isa(axon2_new, "neuron.Section"));
            assert(axon2_new.name == "axon2");
            assert(abs(axon2_new.length - 42) < test.tol);
            assert(isa(soma_new, "neuron.Section"));
            assert(abs(soma_new.length - 100) < test.tol);
            assert(soma_new.nseg == 5);
            assert(soma_new.name == "soma");
            assert(isa(soma_segs{1}, "neuron.Segment"));
            assert(soma_segs{1}.parent_name == "soma");
            assert(numel(soma_segs) == soma_new.nseg);
        end

        function test_morph(test)
            % Call the function to test
            example_morph;
            % Check output.
            assert(abs(main.length - 200) < test.tol);
            assert(main.nseg == 3);
            assert(abs(iclamp.dur - 10000) < test.tol);
            assert(~exist('branch2', 'var'));
        end
    end
    
end
