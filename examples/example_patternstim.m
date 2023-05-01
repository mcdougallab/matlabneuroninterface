clear;
setup;
n = neuron.Neuron();

pc = n.ParallelContext();

cell = n.IntFire1();
cell.refrac = 0;
pc.set_gid2node(0, pc.id());
pc.cell(0, n.NetCon(cell, n.null));

nclist = {};
% This does not work:
for i=0:3
    nclist{end+1} = pc.gid_connect(i, cell); % Warning: returned obj.cTemplate is null.
    nclist{end+1}.weight = 2;
    nclist{end+1}.delay = 1 + 0.1*i;
end 
% Probably issue with neuron.stack.hoc_pop("Object") for methods returning
% a new object.

spike_ts = n.Vector();
spike_ids = n.Vector();
pc.spike_record(-1, spike_ts, spike_ids);

tvec = n.Vector([0 1 2 3 4 5 6 7 8 9]);
gidvec = n.Vector([0 1 2 3 4 5 6 7 8 9]);
ps = n.PatternStim();
ps.play(tvec, gidvec);
delete_nrn_obj(tvec); clear tvec;
delete_nrn_obj(gidvec); clear gidvec;

pc.set_maxstep(10.);
n.finitialize(-65);
pc.psolve(7);

for i=1:length(spike_ts)
    disp(spike_ts(i), spike_ids(i));
end

disp(spike_ts(4));
disp(spike_ids(5));
disp(length(spike_ts));
