function [nsecs, nargs] = push_args(varargin)
% Push cell array of arguments to the NEURON stack; return pushed number of 
% sections nsecs and pushed number of function arguments nargs.
%   [nsecs, nargs] = push_args(varargin)
    nargs = 0;
    nsecs = 0;
    for i=1:length(varargin)
        arg = varargin{i};
        if (isa(arg, "neuron.Section"))
            % Push just a Section to the Section stack.
            nsecs = nsecs + 1;
            arg.push();
        elseif (isa(arg, "neuron.Segment"))
            % Push a Section to the Section stack and a location to the NEURON stack.
            nsecs = nsecs + 1;
            nargs = nargs + 1;
            arg.push();
        else
            % Push an argument to the NEURON stack.
            nargs = nargs + 1;
            neuron.stack.hoc_push(arg);
        end
    end
end