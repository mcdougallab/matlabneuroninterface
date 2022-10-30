function value = hoc_pop(returntype)
    if (returntype=="double")
        value = clib.neuron.hoc_xpop();
    elseif (returntype=="string" || returntype=="char")
        value = clib.neuron.matlab_hoc_strpop();
    elseif (returntype=="Object")
        value = clib.neuron.matlab_hoc_objpop();
    elseif (returntype=="void")
        value = 1.0;
    end
end