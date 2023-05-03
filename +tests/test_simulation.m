classdef test_simulation < matlab.unittest.TestCase

    properties
        tol = 1e-4;
    end
    
    methods(Test)
        
        function test_acpot(self)
            set(0,'DefaultFigureVisible','off');
            example_acpot;
            assert(abs(v2_vec(100) - 8.8916) < self.tol);
            assert(abs(v1_vec(100) - 3.7727) < self.tol);
            assert(abs(t_vec(100) - 2.4750) < self.tol);
            set(0,'DefaultFigureVisible','on');
        end

        function test_alphasynapse(self)
            example_alphasynapse;
            assert(abs(ivec(43) - -1.9125) < self.tol);
            assert(abs(v(101) - 28.7358) < self.tol);
        end

        function test_clamps(self)
            example_clamps;
            assert(abs(c2i_0 - -8.5728e-06) < self.tol);
            assert(abs(c3i_0 - 6.0899e-06) < self.tol);
            assert(abs(s2v_0 - -65.0000) < self.tol);
            assert(abs(s3v_0 - -64.9987) < self.tol);
            assert(abs(c2i_1 - -1.7144e-05) < self.tol);
            assert(abs(c3i_1 - -65.0000) < self.tol);
            assert(abs(s2v_1 - -65.0000) < self.tol);
            assert(abs(s3v_1 - -64.9975) < self.tol);
        end

        function test_intfires(self)
            example_intfires;
            assert(length(cell1out) == 0);
            assert(length(cell2out) == 2);
            assert(abs(cell2out(1) - 7.5365) < self.tol);
            assert(abs(cell2out(2) - 16.1599) < self.tol);
        end

        function test_linearmechanism(self)
            example_linearmechanism;
            assert(abs(n.t - 0.475) < self.tol);
            assert(abs(v_ref.get() - 10) < self.tol);
            assert(abs(y.double(2) - -1.1188) < self.tol);
        end

        function test_netcon(self)
            % TODO: Set random seed; this test goes wrong on second run.
            set(0,'DefaultFigureVisible','off');
            example_netcon;
            assert(abs(t_vec(800) - 19.9750) < self.tol);
            assert(abs(v_vec(800) - 15.9673) < self.tol);
            set(0,'DefaultFigureVisible','on');
        end

        function test_patternstim(self)
            example_patternstim;
            assert(abs(spike_ts(4) - 4.1) < self.tol);
            assert(spike_ids(5) == 0);
            assert(length(spike_ts) == 12);
        end

        function test_savestate(self)
            example_savestate;
            assert(abs(t0 - 0) < self.tol);
            assert(abs(t1 - 0.05) < self.tol);
            assert(abs(t2 - 0) < self.tol);
        end

        function test_temptest(self)
            example_temptest;
            assert(abs(t0 - 6.1000) < self.tol);
            assert(abs(t1 - 6.0676) < self.tol);
            assert(l0 == 1);
            assert(l1 == 1);
            assert(l2 == 0);
        end

    end
    
end
