classdef test_NrnRef < matlab.unittest.TestCase
    methods (Test)
        function testConstructorAndProperties(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            s.nseg = 3;
            % Reference a known range variable (e.g., 'v')
            if any(strcmp(s.range_list, 'v'))
                ref = s.ref('v', 0.5);
                testCase.verifyClass(ref, 'neuron.NrnRef');
                testCase.verifyEqual(ref.ref, 'v');
                testCase.verifyEqual(ref.ref_class, 'RangeVar');
                testCase.verifyGreaterThanOrEqual(ref.length, 1);
            else
                testCase.verifyFail('No known range variable "v" found.');
            end
        end

        function testGetSetSingleValue(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            s.nseg = 1;
            if any(strcmp(s.range_list, 'v'))
                ref = s.ref('v', 0.5);
                old_val = ref();
                ref.set(-65);
                testCase.verifyEqual(ref(), -65, 'AbsTol', 1e-12);
                % Restore old value
                ref.set(old_val);
            else
                testCase.verifyFail('No known range variable "v" found.');
            end
        end

        function testGetSetIndexedValue(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            s.nseg = 3;
            if any(strcmp(s.range_list, 'v'))
                ref = s.ref('v');
                old_val = ref(2);
                ref.set(-70, 2);
                testCase.verifyEqual(ref(2), -70, 'AbsTol', 1e-12);
                % Restore old value
                ref.set(old_val, 2);
            else
                testCase.verifyFail('No known range variable "v" found.');
            end
        end

        function testSubsrefSubsasgn(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            s.nseg = 2;
            if any(strcmp(s.range_list, 'v'))
                ref = s.ref('v');
                old_val = ref(1);
                ref(1) = -60;
                testCase.verifyEqual(ref(1), -60, 'AbsTol', 1e-12);
                % Restore old value
                ref(1) = old_val;
            else
                testCase.verifyFail('No known range variable "v" found.');
            end
        end

        function testSizeAndNumel(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            s.nseg = 3;
            if any(strcmp(s.range_list, 'v'))
                ref = s.ref('v');
                sz = ref.size();
                testCase.verifyEqual(sz(2), ref.length);
                testCase.verifyEqual(ref.numel(), ref.length);
            else
                testCase.verifyFail('No known range variable "v" found.');
            end
        end

        function testErrorOnInvalidIndexing(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            s.nseg = 1;
            if any(strcmp(s.range_list, 'v'))
                ref = s.ref('v');
                testCase.verifyError(@() ref{'bad'}, 'MATLAB:IndexingTypeNotSupported');
            else
                testCase.verifyFail('No known range variable "v" found.');
            end
        end

        function testErrorOnInvalidPropertyOrMethod(testCase)
            n = neuron.launch();
            n.reset_sections();
            n.hoc_oc('create soma');
            s = n.Section('soma');
            s.nseg = 1;
            if any(strcmp(s.range_list, 'v'))
                ref = s.ref('v');
                testCase.verifyError(@() ref.notaprop, 'MATLAB:MethodOrPropertyNotRecognized');
                testCase.verifyError(@() ref.notamethod(), 'MATLAB:MethodOrPropertyNotRecognized');
            else
                testCase.verifyFail('No known range variable "v" found.');
            end
        end
    end
end