% Minimal ParallelContext/IntFire1 example.
% From from https://nrn.readthedocs.io/en/8.2.2/python/modelspec/programmatic/mechanisms/mech.html#PatternStim
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.Neuron();
n.reset_sections();
soma = n.Section("soma");

pc = n.ParallelContext();

% Model
cell = n.IntFire1();
cell.refrac = 0;  % no limit on spike rate
pc.set_gid2node(0, pc.id());
pc.cell(0, n.NetCon(cell, n.null));  % generates a spike with gid=0

nclist = {};
for i=0:3  % note gid=0 recursive connection
    nclist{end+1} = pc.gid_connect(i, cell);
    nclist{end}.weight = 2;  % anything above 1 causes immediate firing for IntFire1
    nclist{end}.delay = 1 + 0.1*i; % incoming (t, gid) generates output (t + 1 + 0.1*gid, 0)
end 

% Record all spikes (cell is the only one generating output spikes)
spike_ts = n.Vector();
spike_ids = n.Vector();
pc.spike_record(-1, spike_ts, spike_ids);

% PatternStim
tvec = n.Vector([0 1 2 3 4 5 6 7 8 9]);
gidvec = n.Vector([0 1 2 3 4 5 6 7 8 9]);
ps = n.PatternStim();
ps.play(tvec, gidvec);
delete(tvec); clear tvec;  
delete(gidvec); clear gidvec;

% Run
pc.set_maxstep(10.);
n.finitialize(-65);
pc.psolve(7);

for i=1:length(spike_ts)
    disp('--------');
    disp(i);
    disp(spike_ts(i))
    disp(spike_ids(i));
end

disp(spike_ts(4));  % 4.1
disp(spike_ids(5));  % 0
disp(length(spike_ts));  % 12
