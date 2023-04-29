% Initialization.
clear;
setup;
n = neuron.Neuron();

s1 = n.Section("s1");
s2 = n.Section("s2");
s3 = n.Section("s3");

sections = n.allsec();
for i=1:numel(sections)
    sections{i}.insert_mechanism("hh");
    sections{i}.set_diameter(3);
    sections{i}.length = 3;
end

c1 = n.IClamp(s1(0.5));
c2 = n.SEClamp(s2(0.5));
c3 = n.VClamp(s3(0.5));
c1.dur = 0.1;
c1.amp = 0.3;
c2.dur1 = 1;
c2.rs = 0.01;
% c3.dur(0) = 1;  % Throws error... c3.dur is a scalar, according to MATLAB.
% c3.dur(2) = 17;  % Throws error... c3.dur is a scalar, according to MATLAB.
c3.dur = 1;
c3.amp = 0;

ap = n.Vector();
ap.record(s1(0.5).ref("v"));
apc = n.Vector();  % This needs to be removed once ap.c() is fixed.
apc.record(s1(0.5).ref("v"));  % This needs to be removed once ap.c() is fixed.
n.finitialize(-65);
while n.t < 1
    n.fadvance();
end

% apc = neuron.Vector(ap.c());  % Problem: this gives a 1xNaN Vector with null apc.obj.cTemplate.

ap.play_remove();
ap.play(c2.ref("amp1"), n.dt);
apc.play(c3.ref("amp"), n.dt);

n.secondorder = 0;

n.finitialize(-65);
n.fadvance();
disp(c2.i);  % These results are correct.
disp(c3.i);
disp(s2(0.5).v);
disp(s3(0.5).v);

n.secondorder = 2;

n.finitialize(-65);
n.fadvance();
disp(c2.i);  % Problem: same results here as for n.secondorder = 0.
disp(c3.i);
disp(s2(0.5).v);
disp(s3(0.5).v);
