classdef test_simulation < matlab.unittest.TestCase

    properties
        tol = 1e-4;
    end
    
    methods(Test)
        
        function test_acpot(test)
            set(0,'DefaultFigureVisible','off');
            example_acpot;
            set(0,'DefaultFigureVisible','on');
            assert(abs(v2_vec(100) - 8.8916) < test.tol);
            assert(abs(v1_vec(100) - 3.7727) < test.tol);
            assert(abs(t_vec(100) - 2.4750) < test.tol);
        end

        function test_alphasynapse(test)
            example_alphasynapse;
            assert(abs(ivec(43) - -1.9125) < test.tol);
            assert(abs(v(101) - 28.7358) < test.tol);
        end

        function test_clamps(test)
            example_clamps;
            assert(abs(c2i_0 - -8.5728e-06) < test.tol);
            assert(abs(c3i_0 - 6.0899e-06) < test.tol);
            assert(abs(s2v_0 - -65.0000) < test.tol);
            assert(abs(s3v_0 - -64.9987) < test.tol);
            assert(abs(c2i_1 - -1.7144e-05) < test.tol);
            assert(abs(c3i_1 - -65.0000) < test.tol);
            assert(abs(s2v_1 - -65.0000) < test.tol);
            assert(abs(s3v_1 - -64.9975) < test.tol);
        end

        function test_intfires(test)
            example_intfires;
            assert(length(cell1out) == 0);
            assert(length(cell2out) == 2);
            assert(abs(cell2out(1) - 7.5365) < test.tol);
            assert(abs(cell2out(2) - 16.1599) < test.tol);
        end

        function test_linearmechanism(test)
            example_linearmechanism;
            assert(abs(n.t - 0.475) < test.tol);
            assert(abs(v_ref.get() - 10) < test.tol);
            assert(abs(y.double(2) - -1.1188) < test.tol);
        end

        function test_netcon(test)
            set(0,'DefaultFigureVisible','off');
            example_netcon;
            set(0,'DefaultFigureVisible','on');
            assert(abs(t_vec(750) - 18.7250) < test.tol);
            assert(abs(v_vec(750) - 8.5781) < test.tol);
        end

        function test_patternstim(test)
            example_patternstim;
            assert(abs(spike_ts(4) - 4.1) < test.tol);
            assert(spike_ids(5) == 0);
            assert(length(spike_ts) == 12);
        end

        function test_savestate(test)
            example_savestate;
            assert(abs(t0 - 0) < test.tol);
            assert(abs(t1 - 0.05) < test.tol);
            assert(abs(t2 - 0) < test.tol);
        end

        function test_temptest(test)
            example_temptest;
            assert(abs(t0 - 6.1000) < test.tol);
            assert(abs(t1 - 6.0676) < test.tol);
            assert(l0 == 1);
            assert(l1 == 1);
            assert(l2 == 0);
        end

    end
    
end
