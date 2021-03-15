function [ SaveArray, SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate, d)

DAG.arrivalTime = 0;
TaskNum=size(DAG.E, 1);
NumPro = size(DAG.Wcet, 1);
rankUvalueInitial = zeros(1, TaskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % 算出每个任务的rank值并排序-论文5.1

DAG = lowerBoundFuc(DAG);   % 算出的最小的AFT
[MSLscheduleLength, MSLScheduleResult] = MSLFuc( DAG, relReq, failureRate);
MSLtotalEnergyConsumption = EnergyConsumptionFuc(MSLScheduleResult, MSLscheduleLength, energySpec);

%[DAG_PM, totalEnergyConsumption_PM, ScheduleResult_PM, failureRate_PM, energySpec_PM, AFT_PM] = ProcessorMergingFuc( DAG, relReq, failureRate, energySpec, MSLscheduleLength); % 只运行融合，以做对比
%[DAG_DVFS, totalEnergyConsumption_DVFS, ScheduleResult_DVFS, frequencyScale_DVFS, AFT_DVFS] = DVFS_TasksFuc( DAG, relReq, failureRate, energySpec, d); % 只运行缩放，以做对比
tic
[DAG_PMDVFSTask, totalEnergyConsumption_PMDVFSTask, ScheduleResult_PMDVFSTask, failureRate_PMDVFSTask, energySpec_PMDVFSTask, AFT_PMDVFS, frequency_PMDVFSTask] = ...
    ProcessorMerging_DVFSTaskFuc( DAG, relReq, failureRate, energySpec, d, MSLscheduleLength); % 运行两程序的融合，以此为主。
toc
SLtime = toc;
figure
GanteForDVFSTasks(ScheduleResult_PMDVFSTask,frequency_PMDVFSTask);

% EnergyConsumptionArray = [totalEnergyConsumption_PMDVFSTask, totalEnergyConsumption_DVFS, totalEnergyConsumption_PM, MSLtotalEnergyConsumption]; % 用来存储三种方法的耗能
% [EnergyConsumptionArray1, EnergyConsumptionIndex] = sort(EnergyConsumptionArray);
% if EnergyConsumptionIndex(1) == 4
%     SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 4]; % 调度时长 耗能
% elseif EnergyConsumptionIndex(1) == 3 % 从三种方式中选择耗能最小的作为输出
%     SaveArray = [AFT_PM, totalEnergyConsumption_PM, MSLtotalEnergyConsumption, 3]; % 调度时长 耗能
% elseif EnergyConsumptionIndex(1) == 2
%     SaveArray = [AFT_DVFS, totalEnergyConsumption_DVFS, MSLtotalEnergyConsumption, 2]; % 调度时长 耗能
% elseif EnergyConsumptionIndex(1) == 1
%     SaveArray = [AFT_PMDVFS, totalEnergyConsumption_PMDVFSTask, MSLtotalEnergyConsumption, 1]; % 调度时长 耗能
% end

for i = 1:NumPro %把调度结果所在的处理器和开始时间保存起来
    eval(strcat('temp = ScheduleResult_PMDVFSTask.processor',num2str(i),';'));
    if ~isempty(temp)
        for j = 1:size(temp,1)
            startTime(temp(j,5)) = temp(j,1);
            inPro(temp(j,5)) = i;
        end
    end
end
if totalEnergyConsumption_PMDVFSTask ~= 0
    dataNeed = [inPro, frequency_PMDVFSTask, startTime];
end

for i = 1:NumPro %做刚开始大量实验的时候用这个
    eval(strcat('GanteFlag = ScheduleResult_PMDVFSTask.processor',num2str(i),';'));
    if isempty(GanteFlag)
        if i==NumPro
            SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
            fprintf(1,'运行失败\n');
        end
        continue
    else
        fprintf(1,'运行成功\n');
        if totalEnergyConsumption_PMDVFSTask <= MSLtotalEnergyConsumption
            SaveArray = [AFT_PMDVFS, totalEnergyConsumption_PMDVFSTask, MSLtotalEnergyConsumption, 1]; % 调度时长 耗能
        else
            SaveArray = [AFT_PMDVFS, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
        end
        break
    end
end
end

