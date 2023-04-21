function all_sections = allsec(section_list)
% Return cell array containing all sections, or all sections in a NEURON
% SectionList section_list (optional).
%   allsec()
%   allsec(section_list)

    % Deal with input.
    if ~exist('section_list', 'var') % No input: get SectionList of all Sections.
        section_list = clib.neuron.get_section_list();
    elseif isa(section_list, 'neuron.Object') % Input is a 'n.SectionList'
        section_list = clib.neuron.get_obj_u_this_pointer(section_list.obj);
    elseif isa(section_list, 'clib.neuron.Object') % Input is a C++ NEURON object
        if clibIsNull(section_list) % If NULL, get SectionList of all Sections.
            section_list = clib.neuron.get_section_list();
        else  % Input is a fair dinkum NEURON SectionList
            section_list = clib.neuron.get_obj_u_this_pointer(section_list);
        end
    end

    section_iter = section_list.next;
    section = clib.neuron.get_hoc_item_element_sec(section_iter);
    all_sections = {neuron.Section(section)};

    % Iterate using section_iter.next.
    while true
        section_iter = section_iter.next;
        section = clib.neuron.get_hoc_item_element_sec(section_iter);
        if clibIsNull(section)
            % End of the section chain.
            break;
        else
            if clibIsNull(section.prop)
                % Invalidated section: do not append, delete and unref.
                clib.neuron.hoc_l_delete(section_iter);
                clib.neuron.section_unref(section);
            else
                % Valid section: append.
                all_sections{end+1} = neuron.Section(section);
            end
        end
    end
end
