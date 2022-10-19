classdef Neuron
% Neuron Class for initializing a Neuron session and running generic Neuron functions.

    methods
        function self = Neuron()
        % Initialize the neuron session, if it has not been initialized before.
        %   Neuron()

            % Strictly speaking this constructor is static; it only 
            % initializes the NEURON session in C++ and does 
            % not store anything in the MATLAB Neuron object.
            clib.neuron.initialize();
            
        end
    end
    methods(Static)
        function create_soma()
        % Create soma by passing "create soma\n" to hoc_oc.
        %   create_soma()
            clib.neuron.create_soma();
        end
        function topology()
        % Print the topology to stdout.txt.
        %   topology()
            clib.neuron.topology();
        end
        function nrnref = ref(sym)
        % Return an NrnRef containing a pointer to a top-level symbol (sym).
        %   nrnref = ref(sym)
            nrnref = clib.neuron.ref(sym);
        end
        function finitialize(v)
        % Initializes a simulation, by providing a voltage (v) in mv.
        %   finitialize(v)
            clib.neuron.finitialize(v);
        end
        function fadvance()
        % Advance the simulation by one timestep.
        %   fadvance()
            clib.neuron.fadvance();
        end
        function close()
        % Close the stderr/stdout txt files.
        %   close()
            clib.neuron.close();
        end
    end
end