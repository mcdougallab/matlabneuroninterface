function hoc_push(value)
% Push a double, string, Vector, Object or NrnRef to the NEURON stack.
%   hoc_push(value)
    if isa(value, "logical")
        clib.neuron.hoc_pushx(double(value));  
    elseif isa(value, "double")
        clib.neuron.hoc_pushx(value);  
    elseif isa(value, "string") || isa(value, "char")
        clib.neuron.matlab_hoc_pushstr(value);  
    elseif isa(value, "neuron.Object")
        clib.neuron.hoc_push_object(value.obj);  
    elseif isa(value, "clib.neuron.Object")
        clib.neuron.hoc_push_object(value);  
    elseif isa(value, "clib.neuron.NrnRef")
        clib.neuron.matlab_hoc_pushpx(value);
    elseif isa(value, "clib.type.nullptr")
        clib.neuron.hoc_push_object(clib.type.nullptr);
    else
        error("Input of type "+class(value)+" not allowed.");
    end
end