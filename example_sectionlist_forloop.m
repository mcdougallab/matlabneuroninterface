% Example: Iterate over all sections in a SectionList using a for-loop

% Assume you have a SectionList object, e.g.:
section_list = neuron.SectionList(); % Replace with your actual SectionList creation

% Create the iterator
it = neuron.SectionListIterator(section_list);

% Iterate using MATLAB for-loop protocol
for sec = it
    if isempty(sec), break; end
    disp(['Section name: ', sec.name]);
    % You can access other Section properties/methods here
end

delete(it); % Clean up resources
