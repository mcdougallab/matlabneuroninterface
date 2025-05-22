classdef FInitializeHandler < handle
% FInitializeHandler Class for setting callbacks used during fintialization. 
    properties
        func_handle
        type
        hoc_object
    end
    methods
        function self = FInitializeHandler(type_or_func_handle, func_handle)

            % Instance id to be reference to this object from C++.
            persistent instance_id
            if isempty(instance_id) 
                instance_id = 0;
            end
            if nargin < 2
                type = 1;
                func_handle = type_or_func_handle;
            else
                type = type_or_func_handle;
            end

            % Create unique id by using constantly increasing id.
            instance_id = instance_id + 1;
            self.func_handle = func_handle;
            self.type = type;

            % Setup reference to self with this new id
            neuron.FInitializeHandler.handlers(self, instance_id);

            % Create unique function name for this handler in hoc name space.
            % Random UUID used as we are polluting the hoc name space.
            uuid = replace(char(matlab.lang.internal.uuid()), "-", "_");
            func_name = "matlab_Neuron_" + uuid;
            self.hoc_object = neuron_api('create_FInitializeHandler', type, char(func_name), char(string(instance_id)));
        end
        function delete(self)
            neuron_api('nrn_object_unref', self.hoc_object);
        end
    end
    methods(Static)
        function handlers(handler_object_or_instance_id, instance_id)
        % Function sets handler value when 2 params are passed and calls handler value when 1 is passed.
        % Used by C++, not intended to be called through matlab.
            % Dict holding references to all the created FInitializeHandlers.
            % Will be used from C++ to call the FInitializeHandlers func_handles.
            persistent handlers;
            if isempty(handlers)
                handlers = dictionary();
            end

            if nargin < 2
            instance_id = handler_object_or_instance_id;
                if (isKey(handlers, instance_id))
                    handler = handlers(instance_id);
                    handler.func_handle();
                else
                    error("Key: " +  instance_id + " not in FInitialize handlers dict.")
                end
                return
            end

            handler_object = handler_object_or_instance_id;
            handlers(instance_id) = handler_object;
        end
    end
end
