n = NEURON.NEURON;

soma = n.Section("soma");
soma.L = 10;
soma.diam = 10;
soma.insert("hh");

ic = n.IClamp(soma.seg(0.5));
ic.amp = 0.3;
ic.delay = 1;
ic.dur = 0.1;

t = n.Vector().record(n.t_ptr);
v = n.Vector().record(soma.seg(0.5).v_ptr);

n.finitialize(-65);
n.continuerun(10);

plot(t.to_matlab(), v.to_matlab(), "linewidth", 4);
xlabel("t (ms)");
ylabel("soma.seg(0.5).v (mV)");