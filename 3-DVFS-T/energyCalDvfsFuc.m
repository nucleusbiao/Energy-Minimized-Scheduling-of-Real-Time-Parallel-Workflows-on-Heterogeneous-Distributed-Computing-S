function energyTotal=energyCalDvfsFuc(in, energySpec, frequencyArray, indexTask)
num=length(fieldnames(in));%获取ECU个数
energy_dynamic = 0;
flag = 0;
for i=1:num
    % energy_static = energy_static + energySpec(i,1)*makeSpanMax;
    temp=['ecu{i}=in.processor',num2str(i),';'];
    eval(temp);
    for j = 1:size(ecu{i}, 1)
        if eq(ecu{i}(j,5), indexTask)
            % energy_dynamic = energy_dynamic + (energySpec(i,2)+energySpec(i,3)*frequencyArray(i)^(energySpec(i,4)))*ecu{i}(j,2)/frequencyArray(i);
            energy_dynamic = energy_dynamic + (energySpec(i,2)+energySpec(i,3)*frequencyArray(i)^(energySpec(i,4)))*ecu{i}(j,2);
            flag = 1;
            break
        end
    end
    if eq(flag, 1)
        break
    end
end
energyTotal = energy_dynamic;