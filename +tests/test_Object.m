classdef test_Object < matlab.unittest.TestCase
    methods (Test)
        function testConstructorAndType(testCase)
            n = neuron.launch();
            v = n.Vector();
            testCase.verifyClass(v, 'neuron.Object');
            testCase.verifyNotEmpty(v.objtype);
        end

        function testDynamicPropertyAccess(testCase)
            n = neuron.launch();
            v = n.Vector();
            v.append(1); v.append(2); v.append(3);
            testCase.verifyEqual(v.size(), [1 3]);
            testCase.verifyEqual(v.length(), 3);
        end

        function testDynamicPropertyAssignment(testCase)
            n = neuron.launch();
            v = n.Vector();
            v.append(1); v.append(2); v.append(3);
            v(2) = 42;
            testCase.verifyEqual(v(2), 42);
        end

        function testMethodCallHoc(testCase)
            n = neuron.launch();
            v = n.Vector();
            v.append(1); v.append(2); v.append(3);
            % sum is a typical method for NEURON Vector
            if any(strcmp(v.apply_func_list, "sum"))
                s = v.apply("sum");
                testCase.verifyEqual(s, 6);
            end
        end

        function testListMethods(testCase)
            n = neuron.launch();
            v = n.Vector();
            testCase.verifyWarningFree(@() v.list_methods());
        end

        function testRefAndGetObj(testCase)
            n = neuron.launch();
            v = n.Vector();
            v.append(1);
            ref = v.ref('size');
            testCase.verifyClass(ref, 'neuron.NrnRef');
            obj = v.get_obj();
            testCase.verifyClass(obj, 'uint64');
        end

        function testDeleteUnref(testCase)
            n = neuron.launch();
            v = n.Vector();
            obj_ptr = v.get_obj();
            v.delete();
            % After deletion, the object should be unref'd in NEURON
            % (This is a soft check; you may want to verify with NEURON API if possible)
            testCase.verifyWarningFree(@() neuron_api('nrn_object_unref', obj_ptr));
        end

        function testErrorOnInvalidProperty(testCase)
            n = neuron.launch();
            v = n.Vector();
            testCase.verifyError(@() v.notaprop, 'MATLAB:unrecognizedStringChoice');
        end

        function testErrorOnInvalidMethod(testCase)
            n = neuron.launch();
            v = n.Vector();
            testCase.verifyError(@() v.notamethod(), 'MATLAB:unrecognizedStringChoice');
        end

        function testSetAndGetSteeredProp(testCase)
            n = neuron.launch();
            v = n.Vector();
            % If 'size' is a steered property
            if isprop(v, 'size')
                v.size = [1 5];
                testCase.verifyEqual(v.size, [1 5]);
            end
        end

        function testSetAndGetArrayProp(testCase)
            n = neuron.launch();
            v = n.Vector();
            % If 'm' is an array property (example, adjust as needed)
            if isprop(v, 'm')
                arr = [1 2 3];
                v.m = arr;
                testCase.verifyEqual(v.m, arr);
            end
        end
    end
end