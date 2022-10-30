function hoc_push(value)
    if (isa(value, "double"))
        clib.neuron.hoc_pushx(value);  
    elseif (isa(value, "string") || isa(value, "char"))
        clib.neuron.matlab_hoc_pushstr(value);  
    elseif (isa(value, "clib.neuron.Vector") || isa(value, "clib.neuron.Object"))
        clib.neuron.matlab_hoc_pushobj(value);  
    elseif (isa(value, "clib.neuron.NrnRef"))
        clib.neuron.matlab_hoc_pushpx(value);
    else
        error("Input of type "+class(value)+" not allowed.");
    end
end