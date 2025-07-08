classdef test_simulation < matlab.unittest.TestCase

    properties
        tol = 1e-10;
        tol_large = 1e-4;
    end
    
    methods(Test)
        
        function test_acpot(testCase)
            set(0,'DefaultFigureVisible','off');
            example_acpot;
            set(0,'DefaultFigureVisible','on');
            testCase.verifyEqual(v2_vec(100), 14.2575892416028, "RelTol", testCase.tol);
            testCase.verifyEqual(v1_vec(100), 6.53771377261781, "RelTol", testCase.tol);
            testCase.verifyEqual(t_vec(100), 2.4750, "RelTol", testCase.tol);
        end

        function test_alphasynapse(testCase)
            example_alphasynapse;
            testCase.verifyEqual(ivec(43), -1.91249419654768, "RelTol", testCase.tol);
            testCase.verifyEqual(v(101), 28.7358157812159, "RelTol", testCase.tol);
        end

        function test_clamps(testCase)
            example_clamps;
            % In this example we use VClamp in a non-recommended way; as a
            % result some test tolerances need to be increased.
            testCase.verifyEqual(c2i_0, -8.57284021549276e-06, "RelTol", testCase.tol);
            testCase.verifyEqual(c3i_0, 6.08992178285916e-06, "RelTol", testCase.tol);
            testCase.verifyEqual(s2v_0, -65, "RelTol", testCase.tol_large);
            testCase.verifyEqual(s3v_0, -64.9975, "RelTol", testCase.tol_large);
            testCase.verifyEqual(c2i_1, -1.71437434914878e-05, "RelTol", testCase.tol);
            testCase.verifyEqual(c3i_1, -65, "RelTol", testCase.tol_large);
            testCase.verifyEqual(s2v_1, -65, "RelTol", testCase.tol_large);
            testCase.verifyEqual(s3v_1, -64.9975, "RelTol", testCase.tol_large);
        end

        function test_intfires(testCase)
            example_intfires;
            testCase.verifyEqual(length(cell1out), 0);
            testCase.verifyEqual(length(cell2out), 2);
            testCase.verifyEqual(cell2out(1), 7.53652449434298, "RelTol", testCase.tol);
            testCase.verifyEqual(cell2out(2), 16.1598979699204, "RelTol", testCase.tol);
        end

        function test_linearmechanism(testCase)
            example_linearmechanism;
            testCase.verifyEqual(n.t, 0.475, "RelTol", testCase.tol);
            testCase.verifyEqual(v_ref.get(), 10, "RelTol", testCase.tol);
            testCase.verifyEqual(y.double(2), -1.118845888228294, "RelTol", testCase.tol);
        end

        function test_netcon(testCase)
            set(0,'DefaultFigureVisible','off');
            example_netcon;
            set(0,'DefaultFigureVisible','on');
            testCase.verifyEqual(t_vec(750), 18.7250, "RelTol", testCase.tol);
            testCase.verifyEqual(v_vec(750), -73.9171252696946, "RelTol", testCase.tol);
        end

        function test_patternstim(testCase)
            example_patternstim;
            testCase.verifyEqual(spike_ts(4), 4.1, "RelTol", testCase.tol);
            testCase.verifyEqual(spike_ids(5), 0);
            testCase.verifyEqual(length(spike_ts), 12);
        end

        function test_savestate(testCase)
            example_savestate;
            testCase.verifyEqual(t0, 0);
            testCase.verifyEqual(t1, 0.05, "RelTol", testCase.tol);
            testCase.verifyEqual(t2, 0);
        end

        function test_temptest(testCase)
            example_temptest;
            testCase.verifyEqual(t0, 6.1, "RelTol", testCase.tol);
            testCase.verifyEqual(t1, 6.06760875204805, "RelTol", testCase.tol);
            testCase.verifyEqual(l0, 1);
            testCase.verifyEqual(l1, 1);
            testCase.verifyEqual(l2, 0);
        end

    end
    
end
