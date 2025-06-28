classdef test_Segment < matlab.unittest.TestCase
    methods (Test)
        function testConstructorAndProperties(testCase)
            n = neuron.launch();
            n.reset_sections();
            n('create soma');
            s = n.Section('soma');
            s.nseg = 3;
            segs = s.segments();
            seg = segs{2};
            testCase.verifyClass(seg, 'neuron.Segment');
            testCase.verifyEqual(seg.parent_sec, s);
            testCase.verifyGreaterThanOrEqual(seg.x, 0);
            testCase.verifyLessThanOrEqual(seg.x, 1);
            testCase.verifyEqual(seg.parent_name, 'soma');
        end

        function testDispAndErrorOnDeletedSection(testCase)
            n = neuron.launch();
            n.reset_sections();
            n('create soma');
            s = n.Section('soma');
            s.nseg = 1;
            seg = s.segments{1};
            % Should display without error
            testCase.verifyWarningFree(@() disp(seg));
            % Delete parent section
            s.delete();
            testCase.verifyError(@() disp(seg), 'MATLAB:ParentSectionDeleted');
        end

        function testPushAndRef(testCase)
            n = neuron.launch();
            n.reset_sections();
            n('create soma');
            s = n.Section('soma');
            s.nseg = 3;
            seg = s.segments{2};
            testCase.verifyWarningFree(@() seg.push());
            % Test ref to a known range variable (e.g., 'v')
            if any(strcmp(s.range_list, 'v'))
                ref = seg.ref('v');
                testCase.verifyClass(ref, 'neuron.NrnRef');
            else
                testCase.verifyFail('No known range variable "v" found.');
            end
        end

        function testSubsrefDynamicRangeVar(testCase)
            n = neuron.launch();
            n.reset_sections();
            n('create soma');
            s = n.Section('soma');
            s.nseg = 3;
            seg = s.segments{2};
            % Access a known range variable (e.g., 'v')
            if any(strcmp(s.range_list, 'v'))
                v_val = seg.v;
                testCase.verifyClass(v_val, 'double');
            else
                testCase.verifyFail('No known range variable "v" found.');
            end
        end

        function testSubsasgnDynamicRangeVar(testCase)
            n = neuron.launch();
            n.reset_sections();
            n('create soma');
            s = n.Section('soma');
            s.nseg = 3;
            seg = s.segments{2};
            % Set a known range variable (e.g., 'v')
            if any(strcmp(s.range_list, 'v'))
                seg.v = -65;
                testCase.verifyEqual(seg.v, -65, 'AbsTol', 1e-12);
            else
                testCase.verifyFail('No known range variable "v" found.');
            end
        end

        function testGetBounds(testCase)
            n = neuron.launch();
            n.reset_sections();
            n('create soma');
            s = n.Section('soma');
            s.nseg = 4;
            seg = s.segments{3};
            [x_lo, x_hi] = seg.get_bounds();
            testCase.verifyGreaterThanOrEqual(x_lo, 0);
            testCase.verifyLessThanOrEqual(x_hi, 1);
            testCase.verifyLessThanOrEqual(x_lo, seg.x);
            testCase.verifyGreaterThanOrEqual(x_hi, seg.x);
        end

        function testErrorOnInvalidSubsrefSubsasgn(testCase)
            n = neuron.launch();
            n.reset_sections();
            n('create soma');
            s = n.Section('soma');
            s.nseg = 1;
            seg = s.segments{1};
            % Invalid property
            testCase.verifyError(@() seg.notaprop, 'MATLAB:unrecognizedStringChoice');
            % Invalid assignment
            testCase.verifyError(@() setfield(seg, 'notaprop', 1), 'MATLAB:unrecognizedStringChoice');
        end
    end
end