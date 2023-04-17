function all_sections = allsec()
% Return cell array containing all sections.
%   allsec()
    section_iter = clib.neuron.get_section_list().next;
    section = clib.neuron.get_hoc_item_element_sec(section_iter);
    all_sections = {section};
    while true
        section_iter = section_iter.next;
        section = clib.neuron.get_hoc_item_element_sec(section_iter);
        if clibIsNull(section)
            break;
        else
            all_sections{end+1} = section;
        end
    end
end
