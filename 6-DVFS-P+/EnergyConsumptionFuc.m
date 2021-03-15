function energyTotal=EnergyConsumptionFuc(in, makeSpanMax, energySpec)
num=length(fieldnames(in));%获取ECU个数
energy_static = 0;
energy_dynamic = 0;
for i=1:num % 动态能耗
    % energy_static = energy_static + energySpec(i,1)*makeSpanMax;
    temp=['ecu{i}=in.processor',num2str(i),';'];
    eval(temp);
    for j = 1:size(ecu{i}, 1)
        energy_dynamic = energy_dynamic + energySpec(i,3)*(ecu{i}(j,2));
    end
end

for i=1:num
    % energy_static = energy_static + energySpec(i,1)*makeSpanMax;
    temp=['ecu{i}=in.processor',num2str(i),';'];
    eval(temp);
    if size(ecu{i}, 1) > 1e-3
        energy_static = energy_static + energySpec(i,2)*makeSpanMax;  % 静态
    end
end
%energy_dynamic
%energy_static
energyTotal = energy_static + energy_dynamic;