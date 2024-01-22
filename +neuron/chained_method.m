function varargout = chained_method(varargs, S, n_processed)
% Deal with a chained method call from subsref for cobj-wrapper classes.
% Input is the output of the previous method (varargs), the input of
% subsref (S) and the number of previously processed elements in S
% (n_processed).
    if numel(S) > n_processed
        % Deal with a method/attribute call chain.
        if numel(varargs) == 1
            [varargout{1:nargout}] = varargs{:}.subsref(S(n_processed+1:end));
        elseif numel(varargs) == 0
            error("Cannot run chained method call on empty method output.");
        else
            error("Cannot run chained method call on multiple method outputs.");
        end
    else
        varargout = varargs;
    end
end

