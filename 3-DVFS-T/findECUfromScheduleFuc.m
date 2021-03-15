function ecuOfPreTask = findECUfromScheduleFuc(schedule, preTask)
ecuOfPreTask = 0;
num=length(fieldnames(schedule));%获取ECU个数
for i=1:num
    temp=['ecu=schedule.processor',num2str(i),';'];
    eval(temp);
    for j = 1:size(ecu, 1)
        if eq(preTask, ecu(j,5))
            ecuOfPreTask = i;
            break
        end
    end
end