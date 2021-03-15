function [makeSpan, schedule] = makeSpanCalFuc(schedule)

makeSpan = 0;
num=length(fieldnames(schedule));%获取ECU个数
for j = 1:num
    temp=['ecu=schedule.processor',num2str(j),';'];
    eval(temp);
    if size(ecu, 1) > 1e-3
        makeSpan = max(makeSpan, max(ecu(end,3)));
    end
end