% Initialization.
clear;
setup;
n = neuron.Neuron();
n.reset_sections();

% Define topology.
main = n.Section("main");
branch1 = n.Section("branch1");
branch2 = n.Section("branch2");
main.set_diameter(5);
branch1.set_diameter(2);
branch2.set_diameter(2);
main.length = 30;
branch1.length = 10;
branch2.length = 20;
branch1.connect(0, main, 1);
branch2.connect(0, main, 1);
main.nseg = 2;
n.define_shape();
main.nseg = 5;
n.topology();

ps_all = n.PlotShape(0);
ps_all.variable("diam");
ps_all.scale(-1, 6);
spi = clib.neuron.get_plotshape_interface(ps_all.obj);
disp(spi.low());
disp(spi.high());
disp(spi.varname());
sl_all = spi.neuron_section_list();
sections_all = neuron.allsec(sl_all);
for i=1:numel(sections_all)
    disp(sections_all{i}.name);
end

sl = n.SectionList();
sl.append(main);
sl.append(branch2);
sections_some = neuron.allsec(sl);
for i=1:numel(sections_some)
    disp(sections_some{i}.name);
end
ps_some = n.PlotShape(sl);
ps_some.variable("diam");
ps_some.scale(-2, 7);
spi = clib.neuron.get_plotshape_interface(ps_some.obj);
disp(spi.low());
disp(spi.high());
disp(spi.varname());

