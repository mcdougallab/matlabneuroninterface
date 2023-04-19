function pop_sections(nsecs)
% Pop nsecs Sections.
%   pop_sections(nsecs)
    for i=1:nsecs
        clib.neuron.nrn_sec_pop();
    end
end