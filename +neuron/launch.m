function n = launch()
% Start a NEURON session.
%   n = neuron.launch()
    neuron_api();

    n = neuron.Session.instance();
end
