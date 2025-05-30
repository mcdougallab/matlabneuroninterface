classdef test_Section < matlab.unittest.TestCase
    methods (Test)
        function testConstructorAndName(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            testCase.verifyClass(s, 'neuron.Section');
            testCase.verifyEqual(s.name, 'soma');
        end

        function testSetGetProperties(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create dend');
            s = n.Section('dend');
            s.L = 123;
            s.nseg = 5;
            s.Ra = 150;
            s.diam = 2.5;
            testCase.verifyEqual(s.L, 123);
            testCase.verifyEqual(s.nseg, 5);
            testCase.verifyEqual(s.Ra, 150);
            testCase.verifyEqual(s.diam, 2.5);
        end

        function testSegmentLocationsAndSegments(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create axon');
            s = n.Section('axon');
            s.nseg = 3;
            locs = s.segment_locations();
            testCase.verifyEqual(length(locs), 3);
            segs = s.segments();
            testCase.verifyEqual(length(segs), 3);
            testCase.verifyClass(segs{1}, 'neuron.Segment');
        end

        function testSegmentsWithEndpoints(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create axon');
            s = n.Section('axon');
            s.nseg = 2;
            segs = s.segments(true);
            testCase.verifyEqual(length(segs), 4); % 2 nseg + 2 endpoints
            testCase.verifyClass(segs{1}, 'neuron.Segment');
        end

        function testAllsegAlias(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create axon');
            s = n.Section('axon');
            s.nseg = 2;
            segs1 = s.segments(true);
            segs2 = s.allseg();
            testCase.verifyEqual(segs1, segs2);
        end

        function testInsertMechanismError(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            testCase.verifyError(@() s.insert_mechanism('notamech'), 'MATLAB:expectedError');
        end

        function testRefRangeVar(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            % Use a known range variable, e.g. 'v'
            if any(strcmp(s.range_list, 'v'))
                ref = s.ref('v', 0.5);
                testCase.verifyClass(ref, 'neuron.NrnRef');
            else
                testCase.verifyFail('No known range variable "v" found.');
            end
        end

        function testDeleteSection(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            sec_ptr = s.get_sec();
            s.delete();
            % After deletion, section should be inactive
            is_active = neuron_api('nrn_section_is_active', sec_ptr);
            testCase.verifyFalse(is_active);
        end

        function testSubsrefAndSubsasgnError(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            s.delete();
            testCase.verifyError(@() s.L, 'MATLAB:expectedError');
            testCase.verifyError(@() s.nseg == 3, 'MATLAB:expectedError');
        end

        function testConnectAndAddpoint(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma, dend');
            soma = n.Section('soma');
            dend = n.Section('dend');
            dend.connect(soma);
            dend.addpoint(0,0,0,1);
            pt3d = dend.get_pt3d();
            testCase.verifySize(pt3d, [5,1]);
        end

        function testInfoAndPsection(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            testCase.verifyWarningFree(@() s.info());
            testCase.verifyWarningFree(@() s.psection());
        end
    end
end