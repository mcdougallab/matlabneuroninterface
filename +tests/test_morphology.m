classdef test_morphology < matlab.unittest.TestCase
    
    methods(Test)
        % Test methods
        
        function test_allsec(~)
            % Call the function to test
            example_allsec;
            % Check output.
            assert(isa(sl, "neuron.Object"));
            assert(sl.objtype == "SectionList");
            assert(isa(axon2_new, "neuron.Section"));
            assert(axon2_new.name == "axon2");
            assert(axon2_new.length == 42);
            assert(isa(soma_new, "neuron.Section"));
            assert(soma_new.length == 100);
            assert(soma_new.nseg == 5);
            assert(soma_new.name == "soma");
            assert(isa(soma_segs{1}, "neuron.Segment"));
            assert(soma_segs{1}.parent_name == "soma");
            assert(numel(soma_segs) == soma_new.nseg);
        end

        function test_morph(~)
            % Call the function to test
            example_morph;
            % Check output.
            assert(main.length == 200);
            assert(main.nseg == 3);
            assert(iclamp.dur == 10000);
            assert(~exist('branch2', 'var'));
        end
    end
    
end
