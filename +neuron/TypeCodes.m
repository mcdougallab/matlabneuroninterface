classdef TypeCodes < handle
% Runtime-discovered NEURON symbol and method type codes.
%
% This avoids depending on parse.ypp integer constants in MATLAB dispatch
% logic, so bindings keep working if NEURON renumbers token/type enums.

    properties (SetAccess=private, GetAccess=public)
        STRING
        VAR
        BLTIN
        FUNCTION
        FUN_BLTIN
        PROCEDURE
        STRINGFUNC
        OBJECTFUNC
        OBJECTVAR
        MECHANISM
        TEMPLATE
        RANGEVAR
        POINT_PROCESS_PROPERTY

        SECTION
        OBFUNCTION
        METHOD_OBFUNC
        METHOD_STRFUNC
        METHOD_SECTIONREF

        USERINT
        USERDOUBLE
        USERPROPERTY
        USERFLOAT

        RAW
    end

    properties (Constant, Access=private)
        REQUIRED_FIELDS = [
            "VAR", "BLTIN", "FUNCTION", "FUN_BLTIN", "PROCEDURE", ...
            "STRINGFUNC", "MECHANISM", "TEMPLATE", "RANGEVAR", ...
            "POINT_PROCESS_PROPERTY", "METHOD_OBFUNC", "METHOD_STRFUNC", ...
            "USERINT", "USERDOUBLE", "USERPROPERTY"
        ]
    end

    methods (Access=private)
        function self = TypeCodes()
            self.reset();
        end
    end

    methods (Static)
        function self = instance()
            persistent uniqueInstance
            if isempty(uniqueInstance) || ~isvalid(uniqueInstance)
                uniqueInstance = neuron.TypeCodes();
                uniqueInstance.discover();
            end
            self = uniqueInstance;
        end
    end

    methods
        function discover(self)
            self.reset();

            self.probe_symbol_type('t', 'VAR');
            self.probe_symbol_type('sin', 'BLTIN');
            self.probe_symbol_type('finitialize', 'FUN_BLTIN');
            self.probe_symbol_type('secname', 'STRINGFUNC');
            self.probe_symbol_type('object_pushed', 'OBJECTFUNC');
            self.probe_symbol_type('hh', 'MECHANISM');
            self.probe_symbol_type('IClamp', 'TEMPLATE');
            self.probe_symbol_type('v', 'RANGEVAR');

            self.probe_symbol_subtype('stoprun', 'USERINT');
            self.probe_symbol_subtype('t', 'USERDOUBLE');
            self.probe_symbol_subtype('nseg', 'USERPROPERTY');

            self.hoc_exec('proc _mn_type_probe_proc() { local x }');
            self.probe_symbol_type('_mn_type_probe_proc', 'PROCEDURE');

            self.hoc_exec('strdef _mn_type_probe_str');
            self.probe_symbol_type('_mn_type_probe_str', 'STRING');

            self.probe_symbol_type('hoc_obj_', 'OBJECTVAR');

            self.discover_template_scoped();
            self.discover_from_class_methods();
            self.discover_from_vector_methods();

            self.validate();
        end

        function ok = validate(self)
            missing = string.empty;
            for i = 1:numel(self.REQUIRED_FIELDS)
                name = self.REQUIRED_FIELDS(i);
                if isnan(self.(name))
                    missing(end + 1) = name; %#ok<AGROW>
                end
            end

            ok = isempty(missing);
            if ~ok
                warning([
                    "neuron.TypeCodes: could not discover type codes for: " + ...
                    join(missing, ", ") + ". Some dispatch paths may fail."
                ]);
            end
        end

        function discover_template_scoped(self)
            probe_lines = {
                'begintemplate _MNTypeProbe'
                'public soma, get_obj'
                'create soma'
                'obfunc get_obj() { return new Vector(1) }'
                'proc init() { soma { L=10 } }'
                'endtemplate _MNTypeProbe'
            };
            probe_src = [strjoin(probe_lines, newline), newline];
            self.hoc_exec(probe_src);
            entries = self.parse_type_entries(neuron_api('get_class_methods', '_MNTypeProbe'));
            if isKey(entries, 'soma')
                code = entries('soma');
                self.set_field('SECTION', code(1));
            end
            if isKey(entries, 'get_obj')
                code = entries('get_obj');
                self.set_field('OBFUNCTION', code(1));
            end
        end
    end

    methods (Access=private)
        function reset(self)
            names = string(properties(self));
            for i = 1:numel(names)
                name = names(i);
                if name == "RAW"
                    self.RAW = containers.Map('KeyType', 'char', 'ValueType', 'double');
                else
                    self.(name) = NaN;
                end
            end
        end

        function probe_symbol_type(self, symbol_name, field_name)
            sym = neuron_api('nrn_symbol', symbol_name);
            if isempty(sym) || sym == 0
                return;
            end
            code = neuron_api('nrn_symbol_type', sym);
            self.set_field(field_name, code);
        end

        function probe_symbol_subtype(self, symbol_name, field_name)
            sym = neuron_api('nrn_symbol', symbol_name);
            if isempty(sym) || sym == 0
                return;
            end
            code = neuron_api('nrn_symbol_subtype', sym);
            self.set_field(field_name, code);
        end

        function discover_from_class_methods(self)
            % Probe class member types directly from NEURON class symbol tables.
            vector_entries = self.parse_type_entries(neuron_api('get_class_methods', 'Vector'));
            if isKey(vector_entries, 'x')
                code = vector_entries('x');
                self.set_field('VAR', code(1));
            end

            iclamp_entries = self.parse_type_entries(neuron_api('get_class_methods', 'IClamp'));
            for probe_name = {'amp', 'dur', 'del'}
                name = probe_name{1};
                if isKey(iclamp_entries, name)
                    code = iclamp_entries(name);
                    self.set_field('POINT_PROCESS_PROPERTY', code(1));
                    break;
                end
            end
        end

        function discover_from_vector_methods(self)
            vec_obj = neuron_api('nrn_object_new', 'Vector', 0);
            if isempty(vec_obj) || vec_obj == 0
                return;
            end

            try
                self.probe_method_type(vec_obj, 'size', 'FUNCTION');
                self.probe_method_type(vec_obj, 'c', 'METHOD_OBFUNC');
                self.probe_method_type(vec_obj, 'label', 'METHOD_STRFUNC');
            catch
                % Leave missing fields as NaN; validate() reports them.
            end

            neuron_api('nrn_object_unref', vec_obj);
            self.set_field('OBFUNCTION', self.METHOD_OBFUNC);
        end

        function probe_method_type(self, obj_ptr, method_name, field_name)
            sym = neuron_api('nrn_method_symbol', obj_ptr, method_name);
            if isempty(sym) || sym == 0
                return;
            end
            code = neuron_api('nrn_symbol_type', sym);
            self.set_field(field_name, code);
        end

        function set_field(self, field_name, code)
            if isempty(code)
                return;
            end
            code = double(code);
            self.(field_name) = code;
            self.RAW(field_name) = code;
        end

        function map = parse_type_entries(~, entry_string)
            map = containers.Map('KeyType', 'char', 'ValueType', 'any');
            entries = split(string(entry_string), ';');
            entries = entries(entries ~= "");
            for i = 1:numel(entries)
                kv = split(entries(i), ':');
                if numel(kv) ~= 2
                    continue;
                end
                name = char(kv(1));
                types = split(kv(2), '-');
                if numel(types) ~= 2
                    continue;
                end
                t = str2double(types(1));
                st = str2double(types(2));
                if ~isnan(t) && ~isnan(st)
                    map(name) = [t, st];
                end
            end
        end

        function hoc_exec(self, command)
            cleanup = onCleanup(@() self.clear_hoc_buffer());
            neuron_api('nrn_hoc_call', command);
            clear cleanup;
        end

        function clear_hoc_buffer(~)
            try
                neuron_api('nrn_hoc_call', '');
            catch
                % Ignore cleanup failures; this is best-effort parser reset.
            end
        end
    end
end