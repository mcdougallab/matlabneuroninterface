function n = launch()
% Start a Neuron session.
%   n = neuron.launch()
    neuron_api();

    n = neuron.Session.instance();
end
