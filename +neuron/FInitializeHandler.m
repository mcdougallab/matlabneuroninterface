classdef FInitializeHandler < handle
% FInitializeHandler Class for setting callbacks used during fintialization. 
    properties
        func_handle
        type
        hoc_object
    end
    methods
        function self = FInitializeHandler(type_or_func_handle, func_handle)
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

            instance_id = instance_id + 1;
            self.func_handle = func_handle;
            self.type = type;

            neuron.FInitializeHandler.handlers(self, instance_id);
            func_name = "neuron_FInitializeHandler_" + instance_id + "_9b543_hl5345";
            self.hoc_object = clib.neuron.create_FInitializeHandler(type, func_name, string(instance_id));
        end
        function delete(self)
            clib.neuron.hoc_obj_unref(self.hoc_object);
        end
    end
    methods(Static)
        function handlers(handler_object_or_instance_id, instance_id)
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
