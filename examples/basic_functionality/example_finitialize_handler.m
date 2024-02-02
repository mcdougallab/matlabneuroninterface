n = neuron.Neuron();

disp("Initial state")
disp("-------------------")
global sec
sec = n.Section("my_section");
sec.nseg = 3;
sec.info();

disp("-------------------")
disp("Changes to 47")
disp("-------------------")

a = n.FInitializeHandler(@set_0_833_to_47);
n.finitialize(-65);
sec.info()

disp("-------------------")
disp("Changes to 47 and to 20")
disp("-------------------")

b = n.FInitializeHandler(2, @set_0_166_to_20);
n.finitialize(-65);
sec.info();

delete(a);
delete(b);

disp("-------------------")
disp("No changes since objects have been deleted")
disp("-------------------")

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
