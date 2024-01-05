function n = launch()
% Start a Neuron session.
%   n = neuron.launch()
    if clib.neuron.isinitialized()
        warning("Neuron is already initialized: returned " + ...
            "neuron.Session handle refers to the same object as before.");
    end
    n = neuron.Session();
end
