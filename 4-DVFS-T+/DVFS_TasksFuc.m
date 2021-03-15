function [DAG, totalEnergyConsumption, scheduleOut, frequencyArrayFinal, makeSpan] = DVFS_TasksFuc( DAG, relReq, failureRate, energySpec, d)

numProcessor = size(DAG.Wcet, 1); %下面几行到空行之前是初始化
numTask = size(DAG.Wcet, 2) - 1; 
frequencyScale(1:numTask) = 1; % 每个任务缩放集合的初始化
DAG_backup = DAG;
failureRate_backup = failureRate;
frequencyArrayFinal(1:numTask) = 1;
for k = 1:numProcessor
    eval(strcat('scheduleOut.processor',num2str(k),'=[];'));
end
[MSLscheduleLength, MSLScheduleResult, relPerTask] = MSLFuc( DAG_backup, relReq, failureRate_backup);
% totalEnergyConsumption = EnergyConsumptionFuc(ScheduleResult, AFTForiTask, energySpec);
makeSpan = MSLscheduleLength;
% figure
% GanteForDVFSTasks(ScheduleResult, frequencyScale)
if MSLscheduleLength == 0
    totalEnergyConsumption = 0;
elseif MSLscheduleLength > DAG.relativeDeadline
    totalEnergyConsumption = 0;
    % fprintf(1,'ProcessorMerging函数中17行左右无法满足截至时间\n\n');
else
    [reliabilitySum, reliPerTask]=relCal(MSLScheduleResult, failureRate);
%     relTotal = 1;
%     for i = 1:numTask % R(G)
%         relTotal = relTotal * relPerTask(i);
%     end
%     Br = (relReq / relTotal)^(1/numTask); % 不变的reliability ratio
    Br = (relReq / reliabilitySum)^(1/numTask); % 不变的reliability ratio
    % totalEnergyConsumption_backup = EnergyConsumptionFreqFuc(ScheduleResult_backup, AFTForiTask_backup, energySpec, frequencyScale); %
    [makeSpan, scheduleOut, frequencyArrayFinal] = scheduleFunctionDVFSFuc(MSLScheduleResult, DAG_backup, ...
        Br, reliPerTask, relReq, failureRate, energySpec, d);
    totalEnergyConsumption = energyCalPerTaskFuc(scheduleOut, energySpec, frequencyArrayFinal);
end
end

