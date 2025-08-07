function [nsecs, nargs] = push_args(varargin)
% Push cell array of arguments to the NEURON stack; return pushed number of 
% sections nsecs and pushed number of function arguments nargs.
%   [nsecs, nargs] = push_args(args...)
%   [nsecs, nargs] = push_args(args..., string_stack)
    
    % Check if last argument is a string_stack (uint64 pointer)
    string_stack = [];
    args = varargin;
    
    if nargin > 0 && isa(varargin{end}, 'uint64') && numel(varargin{end}) == 1
        % Last argument might be string_stack
        string_stack = varargin{end};
        args = varargin(1:end-1);
    end
    
    nargs = 0;
    nsecs = 0;
    for i=1:length(args)
        arg = args{i};
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
            neuron.stack.hoc_push(arg, string_stack);
        end
    end
end