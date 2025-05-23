% Minimal Intfire2/IntFire4/NetStim/NetCon example.
clearvars -except testCase;  % Make sure testing params are not cleared.
n = neuron.launch();
n.reset_sections();
soma = n.Section('soma');

n.load_file('stdrun.hoc');

cell1 = n.IntFire2();
cell1.taum = 5;
cell1.taus = 2;
cell2 = n.IntFire4();
cell2.taue = 5;
cell2.taui1 = 0.5;
cell2.taui2 = 10;

ns = n.NetStim();
ns.start = 5;
ns.number = 4;
ns.noise = 0;

ns2 = n.NetStim();
ns2.start = 9;
ns2.number = 1;
ns.noise = false;

nc1a = n.NetCon(ns, cell1, 0, 0, 2);
nc2a = n.NetCon(ns, cell2, 0, 0, 2);
nc1b = n.NetCon(ns2, cell1, 0, 0, -1);
nc2b = n.NetCon(ns2, cell2, 0, 0, -1);

cell1out = n.Vector();
cell2out = n.Vector();
cell1out_nc = n.NetCon(cell1, n.null);
cell2out_nc = n.NetCon(cell2, n.null);
cell1out_nc.record(cell1out);
cell2out_nc.record(cell2out);

n.finitialize(-65);
n.continuerun(20);

disp(length(cell1out));  % 0
disp(length(cell2out));  % 2
disp(cell2out(1));  % 7.5365
disp(cell2out(2));  % 16.1599
