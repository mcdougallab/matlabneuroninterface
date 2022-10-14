classdef Neuron
    methods(Static)
        function obj = Neuron()
            clib.neuron.initialize();
        end
        function create_soma()
            clib.neuron.create_soma();
        end
        function topology()
            clib.neuron.topology();
        end
        function value = ref(x)
            value = clib.neuron.ref(x);
        end
        function finitialize(x)
            clib.neuron.finitialize(x);
        end
        function fadvance()
            clib.neuron.fadvance();
        end
        function close()
            clib.neuron.close();
        end
    end
end