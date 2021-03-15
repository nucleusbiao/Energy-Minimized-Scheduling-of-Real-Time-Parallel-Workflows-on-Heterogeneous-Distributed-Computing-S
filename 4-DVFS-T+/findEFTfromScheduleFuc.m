function EFTofPreTask = findEFTfromScheduleFuc(schedule, preTask)

num=length(fieldnames(schedule));%获取ECU个数
EFTofPreTask = 0;
for i=1:num
    temp=['ecu=schedule.processor',num2str(i),';'];
    eval(temp);
    for j = 1:size(ecu, 1)
        if eq(preTask, ecu(j,5))
            EFTofPreTask = ecu(j,3);
            break
        end
    end
end