% The Neuron class is used to initialize a Neuron session. It also 
% contains static methods for running generic Neuron functions.

classdef Neuron
    methods
        function self = Neuron()
        % Initialize NEURON session. 

            % Strictly speaking this constructor is static; it only 
            % initializes the NEURON session in C++ and does 
            % not store anything in the MATLAB Neuron object.
            clib.neuron.initialize();
            
        end
    end
    methods(Static)
        function create_soma()
        % Pass "create soma\n" to hoc_oc.
            clib.neuron.create_soma();
        end
        function topology()
        % Print the topology to stdout.txt
            clib.neuron.topology();
        end
        function value = ref(sym)
        % Get an NrnRef containing a pointer to a top-level symbol.
            value = clib.neuron.ref(sym);
        end
        function finitialize(v)
        % Initialize a simulation, provide a voltage in mv.
            clib.neuron.finitialize(v);
        end
        function fadvance()
        % Advance the simulation by one timestep.
            clib.neuron.fadvance();
        end
        function close()
        % Close the stderr/stdout txt files.
            clib.neuron.close();
        end
    end
end