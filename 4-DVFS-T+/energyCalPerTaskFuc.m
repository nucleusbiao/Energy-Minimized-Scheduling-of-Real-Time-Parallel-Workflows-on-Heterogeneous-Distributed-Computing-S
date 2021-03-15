function energyTotal=energyCalPerTaskFuc(in, energySpec, frequencyFinalArray)
num=length(fieldnames(in));%获取ECU个数
energy_dynamic = 0;
energy_static = 0;
scheduleLength = 0;
for i=1:num
    % energy_static = energy_static + energySpec(i,1)*makeSpanMax;
    temp=['ecu{i}=in.processor',num2str(i),';'];
    eval(temp);
    if size(ecu{i}, 1) > 1e-3
        scheduleLength = max(scheduleLength,max(ecu{i}(:,3)));
    end
    for j = 1:size(ecu{i}, 1)
        energy_dynamic = energy_dynamic + (energySpec(i,3)*frequencyFinalArray(ecu{i}(j,5))^(energySpec(i,4)))*ecu{i}(j,2);
    end
end

for i=1:num
    % energy_static = energy_static + energySpec(i,1)*makeSpanMax;
    temp=['ecu{i}=in.processor',num2str(i),';'];
    eval(temp);
    if size(ecu{i}, 1) > 1e-3
        energy_static = energy_static + energySpec(i,2)*scheduleLength;
    end
end
energyTotal = energy_static + energy_dynamic;