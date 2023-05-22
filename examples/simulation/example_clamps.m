% Minimal IClamp/SEClamp/VClamp/secondorder example.
% adapted from https://nrn.readthedocs.io/en/8.2.2/python/modelspec/programmatic/mechanisms/mech.html#SEClamp
% conceptually: this simulates an action potential, records it,
% then feeds that in to various types of voltage clamps and sees
% how much extra current they need to stabilize and how close the
% voltage gets

clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.Neuron();
n.reset_sections();

% setup for three simulations
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
c3.dur(1) = 1;
c3.dur(3) = 17;
c3.amp = [0, 0, 0];

% record an action potential
ap = n.Vector();
ap.record(s1(0.5).ref("v"));
n.finitialize(-65);
while n.t < 1
    n.fadvance();
end

% do the three cases while playing the recorder ap
apc = ap.c();  % unfortunately, cannot play into two variables, so clone it

ap.play_remove();
ap.play(c2.ref("amp1"), n.dt);
apc.play(c3.ref("amp"), n.dt);

n.secondorder = 0;

n.finitialize(-65);
n.fadvance();

% For testing...
c2i_0 = c2.i;
c3i_0 = c3.i;
s2v_0 = s2(0.5).v;
s3v_0 = s3(0.5).v;

disp(c2.i);  % -8.5728e-06
disp(c3.i);  % 6.0899e-06
disp(s2(0.5).v);  % -65.0000
disp(s3(0.5).v);  % -64.9987

% using second order will give somewhat different results
% and is in particular not recommended for the two electrode
% voltage clamp VClamp as that system is numerically stiff
n.secondorder = 2;

n.finitialize(-65);
n.fadvance();

% For testing...
c2i_1 = c2.i;
c3i_1 = c3.i;
s2v_1 = s2(0.5).v;
s3v_1 = s3(0.5).v;

disp(c2.i);  % -1.7144e-05
disp(c3.i);  % -65.0000, NOTE: very different from first order (stiffness issue)
disp(s2(0.5).v);  % -65.0000
disp(s3(0.5).v);  % -64.9975

% Reset.
n.secondorder = 0;
