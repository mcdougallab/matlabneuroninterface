classdef Neuron
    methods(Static)
        function self = Neuron()
            clib.neuron.initialize();
        end
        function create_soma()
            clib.neuron.create_soma();
        end
        function topology()
            clib.neuron.topology();
        end
        function value = ref(sym)
            value = clib.neuron.ref(sym);
        end
        function value = range_ref(sec, sym, val)
            value = clib.neuron.range_ref(sec.sec, sym, val);
        end
        function finitialize(v)
            clib.neuron.finitialize(v);
        end
        function fadvance()
            clib.neuron.fadvance();
        end
        function close()
            clib.neuron.close();
        end
    end
end