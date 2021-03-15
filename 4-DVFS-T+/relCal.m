function [reliabilitySum, reliPerTask]=relCal(in, failureRate)

reliabilitySum = 1;
num=length(fieldnames(in));%获取ECU个数
reliPerTask = [];
for i=1:num
    temp=['ecu{i}=in.processor',num2str(i),';'];
    eval(temp);
    for j = 1:size(ecu{i}, 1)
        reliPerTask(ecu{i}(j,5)) = exp(failureRate(i)*(-ecu{i}(j,2)));
        reliabilitySum = reliabilitySum * exp(failureRate(i)*(-ecu{i}(j,2)));
    end
end
