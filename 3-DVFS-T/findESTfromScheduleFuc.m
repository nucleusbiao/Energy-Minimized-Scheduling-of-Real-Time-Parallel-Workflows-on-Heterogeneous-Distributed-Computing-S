function ESTofAftTask = findESTfromScheduleFuc(schedule, aftTask)

num=length(fieldnames(schedule));%获取ECU个数
ESTofAftTask = 0;
for i=1:num
    temp=['ecu=schedule.processor',num2str(i),';'];
    eval(temp);
    for j = 1:size(ecu, 1)
        if eq(aftTask, ecu(j,5))
            ESTofAftTask = ecu(j,1);
            break
        end
    end
end