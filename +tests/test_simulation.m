classdef test_simulation < matlab.unittest.TestCase

    properties
        tol = 1e-10;
    end
    
    methods(Test)
        
        function test_acpot(testCase)
            set(0,'DefaultFigureVisible','off');
            example_acpot;
            set(0,'DefaultFigureVisible','on');
            testCase.verifyEqual(v2_vec(100), 8.8916, "RelTol", testCase.tol);
            testCase.verifyEqual(v1_vec(100), 3.7727, "RelTol", testCase.tol);
            testCase.verifyEqual(t_vec(100), 2.4750, "RelTol", testCase.tol);
        end

        function test_alphasynapse(testCase)
            example_alphasynapse;
            testCase.verifyEqual(ivec(43), -1.9125, "RelTol", testCase.tol);
            testCase.verifyEqual(v(101), 28.7358, "RelTol", testCase.tol);
        end

        function test_clamps(testCase)
            example_clamps;
            testCase.verifyEqual(c2i_0, -8.5728e-06, "RelTol", testCase.tol);
            testCase.verifyEqual(c3i_0, 6.0899e-06, "RelTol", testCase.tol);
            testCase.verifyEqual(s2v_0, -65.0000, "RelTol", testCase.tol);
            testCase.verifyEqual(s3v_0, -64.9987, "RelTol", testCase.tol);
            testCase.verifyEqual(c2i_1, -1.7144e-05, "RelTol", testCase.tol);
            testCase.verifyEqual(c3i_1, -65.0000, "RelTol", testCase.tol);
            testCase.verifyEqual(s2v_1, -65.0000, "RelTol", testCase.tol);
            testCase.verifyEqual(s3v_1, -64.9975, "RelTol", testCase.tol);
        end

        function test_intfires(testCase)
            example_intfires;
            testCase.verifyEqual(length(cell1out), 0);
            testCase.verifyEqual(length(cell2out), 2);
            testCase.verifyEqual(cell2out(1), 7.5365, "RelTol", testCase.tol);
            testCase.verifyEqual(cell2out(2), 16.1599, "RelTol", testCase.tol);
        end

        function test_linearmechanism(testCase)
            example_linearmechanism;
            testCase.verifyEqual(n.t, 0.475, "RelTol", testCase.tol);
            testCase.verifyEqual(v_ref.get(), 10, "RelTol", testCase.tol);
            testCase.verifyEqual(y.double(2), -1.1188, "RelTol", testCase.tol);
        end

        function test_netcon(testCase)
            set(0,'DefaultFigureVisible','off');
            example_netcon;
            set(0,'DefaultFigureVisible','on');
            testCase.verifyEqual(t_vec(750), 18.7250, "RelTol", testCase.tol);
            testCase.verifyEqual(v_vec(750), 8.5781, "RelTol", testCase.tol);
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
            testCase.verifyEqual(t0, 6.1000, "RelTol", testCase.tol);
            testCase.verifyEqual(t1, 6.0676, "RelTol", testCase.tol);
            testCase.verifyEqual(l0, 1);
            testCase.verifyEqual(l1, 1);
            testCase.verifyEqual(l2, 0);
        end

    end
    
end
