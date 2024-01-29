function example_mpi()
% Run from command prompt with: mpiexec -n 2 matlab -batch "cd ABSOLUTE_PATH_TO_MATLABNEURON; setup; example_mpi"
% On windows, make sure to use neuron's provided mpiexec (usually at C:\nrn\bin\mpiexec.exe).

    n = neuron.Neuron();
    n.nrnmpi_init();
    pc = n.ParallelContext();
    disp("I am " + num2str(pc.id()) + " of " + num2str(pc.nhost()));
    pc.done();
    % Close this matlab session
    exit(0);

end
