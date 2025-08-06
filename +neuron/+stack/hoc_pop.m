function value = hoc_pop(returntype)
% Pop an object of type returntype ("double", "string", "Object" or "void") off the NEURON stack.
%   hoc_pop(returntype)
    if (returntype=="double")
        value = neuron_api('nrn_double_pop');
    elseif (returntype=="string" || returntype=="char")
        value = neuron_api('nrn_str_pop');
    elseif (returntype=="ref")
        % For NrnRef objects.
        value = neuron_api('nrn_double_ptr_pop');
    elseif (returntype=="Object")
        obj = neuron_api('nrn_object_pop');
        objtype = neuron_api('nrn_class_name', obj);
        if objtype == "Vector"
            value = neuron.Vector(obj);
        elseif objtype == "PlotShape"
            value = neuron.PlotShape(obj);
        elseif objtype == "RangeVarPlot"
            value = neuron.RangeVarPlot(obj);
        else
            value = neuron.Object(obj);
        end
    elseif (returntype=="void")
        % For procedures returning nothing.
        value = 1.0;
    end
end