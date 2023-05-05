% Try to cause a crash while running NEURON in MATLAB
clearvars -except test;  % Make sure testing params are not cleared.
n = neuron.Neuron();
n.reset_sections();
as = n.allsec();
disp(as{1});
