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

% Make PlotShape of all Sections.
ps_all = n.PlotShape(0);
ps_all.variable("diam");
ps_all.scale(-1, 6);
spi_all = clib.neuron.get_plotshape_interface(ps_all.obj);
disp(spi_all.low());
disp(spi_all.high());
disp(spi_all.varname());
sl_all = spi_all.neuron_section_list();
sections_all = neuron.allsec(sl_all);
for i=1:numel(sections_all)
    disp(sections_all{i}.name);
    sections_all{i}.info();
end

% Make PlotShape of some Sections.
sl_some = n.SectionList();
sl_some.append(main);
sl_some.append(branch2);
ps_some = n.PlotShape(sl_some);
ps_some.variable("v");
ps_some.scale(-1, 6);
spi_some = clib.neuron.get_plotshape_interface(ps_some.obj);
disp(spi_some.low());
disp(spi_some.high());
disp(spi_some.varname());
sl_all = spi_some.neuron_section_list();
sections_some = neuron.allsec(sl_some);
for i=1:numel(sections_some)
    disp(sections_some{i}.name);
    sections_some{i}.info();
    % Here, spi_some.varname() should be used to select the right range var
    % to plot at each Segment. Then a 3D plot can be made of
    % spi_som.varname() at each Segment location, with lower bound
    % spi_some.low() and upper bound spi_some.high().
end
