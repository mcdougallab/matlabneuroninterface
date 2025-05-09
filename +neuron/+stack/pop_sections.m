function pop_sections(nsecs)
% Pop nsecs Sections.
%   pop_sections(nsecs)
    for i=1:nsecs
        neuron_api('nrn_section_pop');
    end
end