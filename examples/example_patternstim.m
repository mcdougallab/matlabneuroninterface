clear;
setup;
n = neuron.Neuron();

pc = n.ParallelContext();

cell = n.IntFire1();
cell.refrac = 0;
pc.set_gid2node(0, pc.id());
pc.cell(0, n.NetCon(cell, n.null));

% This does not work:
% ncobj = pc.gid_connect(0, cell);
% nc = neuron.Object("NetCon", ncobj);  % Crash.
% Is there an issue with neuron.stack.hoc_pop("Object")?

% nclist = {};
% for i=0:3
%     nclist{end+1} = neuron.Object("NetCon", ...
%         pc.gid_connect(i, cell));
%     nclist{end+1}.weight = 2;
%     nclist{end+1}.delay = 1 + 0.1*i;
% end