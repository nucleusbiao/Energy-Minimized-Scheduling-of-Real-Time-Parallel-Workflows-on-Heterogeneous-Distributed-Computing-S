function [DAG, totalEnergyConsumption, scheduleOut, frequencyArrayFinal, makeSpan] = DVFS_TasksFuc( DAG, relReq, failureRate, energySpec, d)

numProcessor = size(DAG.Wcet, 1); %���漸�е�����֮ǰ�ǳ�ʼ��
numTask = size(DAG.Wcet, 2) - 1; 
frequencyScale(1:numTask) = 1; % ÿ���������ż��ϵĳ�ʼ��
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
    % fprintf(1,'ProcessorMerging������17�������޷��������ʱ��\n\n');
else
    [reliabilitySum, reliPerTask]=relCal(MSLScheduleResult, failureRate);
%     relTotal = 1;
%     for i = 1:numTask % R(G)
%         relTotal = relTotal * relPerTask(i);
%     end
%     Br = (relReq / relTotal)^(1/numTask); % �����reliability ratio
    Br = (relReq / reliabilitySum)^(1/numTask); % �����reliability ratio
    % totalEnergyConsumption_backup = EnergyConsumptionFreqFuc(ScheduleResult_backup, AFTForiTask_backup, energySpec, frequencyScale); %
    [makeSpan, scheduleOut, frequencyArrayFinal] = scheduleFunctionDVFSFuc(MSLScheduleResult, DAG_backup, ...
        Br, reliPerTask, relReq, failureRate, energySpec, d);
    totalEnergyConsumption = energyCalPerTaskFuc(scheduleOut, energySpec, frequencyArrayFinal);
end
end

