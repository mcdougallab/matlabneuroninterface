function value = hoc_pop(returntype)
% Pop an object of type returntype ("double", "string", "Object" or "void") off the NEURON stack.
%   hoc_pop(returntype)
    if (returntype=="double")
        value = clib.neuron.hoc_xpop();
    elseif (returntype=="string" || returntype=="char")
        value = clib.neuron.matlab_hoc_strpop();
    elseif (returntype=="Object")
        obj = clib.neuron.matlab_hoc_objpop();
        % obj = clib.neuron.hoc_pop_object();
        % hoc_pop_object is not used but might be useful in the future for 
        % dealing with methods that return new objects, so I am leaving it 
        % commented for now.
        value = neuron.Object(obj.ctemplate.sym.name, obj);
    elseif (returntype=="void")
        % For procedures returning nothing.
        value = 1.0;
    end
end