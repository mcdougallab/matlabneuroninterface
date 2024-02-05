n = neuron.Neuron();

disp("Initial state")
disp("-------------------")
global sec
sec = n.Section("my_section");
clib.neuron.nrn_change_nseg(sec.sec, 3);
sec.info();

disp("-------------------")
disp("Changes to 47")
disp("-------------------")

a = neuron.FInitializeHandler(@set_0_833_to_47);
n.finitialize(-65);
sec.info()

disp("-------------------")
disp("Changes to 47 and to 20")
disp("-------------------")

b = neuron.FInitializeHandler(2, @set_0_166_to_20);
n.finitialize(-65);
sec.info();

function set_0_833_to_47()
    global sec;
    sec_v = sec.ref("v", 0.833333);
    sec_v.set(47);
end

function set_0_166_to_20()
    global sec;
    sec_v = sec.ref("v", 0.16667);
    sec_v.set(20);
end
