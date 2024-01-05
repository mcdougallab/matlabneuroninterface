function value = hoc_pop(returntype)
% Pop an object of type returntype ("double", "string", "Object" or "void") off the NEURON stack.
%   hoc_pop(returntype)
    if (returntype=="double")
        value = clib.neuron.hoc_xpop();
    elseif (returntype=="string" || returntype=="char")
        value = clib.neuron.matlab_hoc_strpop();
    elseif (returntype=="Object")
        obj = clib.neuron.matlab_hoc_objpop();
        objtype = obj.ctemplate.sym.name;
        if objtype == "Vector"
            value = neuron.Vector(obj);
        else
            value = neuron.Object(obj);
        end
    elseif (returntype=="void")
        % For procedures returning nothing.
        value = 1.0;
    end
end