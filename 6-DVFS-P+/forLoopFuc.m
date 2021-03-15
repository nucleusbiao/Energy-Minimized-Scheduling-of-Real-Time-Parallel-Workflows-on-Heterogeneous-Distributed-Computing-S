function [ SaveArray, SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate)
%% 论文5.1中的优先级排序
DAG.arrivalTime = 0;
TaskNum = size(DAG.Wcet, 2) - 1;
NumPro = size(DAG.Wcet, 1);
rankUvalueInitial = zeros(1, TaskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % 算出每个任务的rank值并排序

%% 计算总能量消耗
d = 3;   %代表失败率对电压缩放的敏感程度
[MSLscheduleLength, MSLScheduleResult] = MSLFuc( DAG, relReq, failureRate);
MSLtotalEnergyConsumption = EnergyConsumptionFuc(MSLScheduleResult, MSLscheduleLength, energySpec);

% [DAG_PM, totalEnergyConsumption_PM, ScheduleResult_PM, failureRate_PM, energySpec_PM, AFT_PM] = ProcessorMergingFuc( DAG, relReq, failureRate, energySpec, MSLscheduleLength); % 只运行融合，以做对比
% [DAG_DVFS, totalEnergyConsumption_DVFS, ScheduleResult_DVFS, frequencyScale_DVFS, AFT_DVFS] = DVFS_ProcessorFuc( DAG, relReq, failureRate, energySpec, d, NumPro); % 只运行缩放，以做对比
tic
[DAG_PMDVFS, totalEnergyConsumption_PMDVFS, ScheduleResult_PMDVFS, failureRate_PMDVFS, energySpec_PMDVFS, AFT_PMDVFS, frequencyScale_PMDVFS] = ...
    ProcessorMerging_DVFSFuc( DAG, relReq, failureRate, energySpec, d, MSLscheduleLength); % 运行两程序的融合，以此为主。
toc
SLtime = toc;
figure
GanteForDVFSPro(ScheduleResult_PMDVFS, frequencyScale_PMDVFS);

% EnergyConsumptionArray = [totalEnergyConsumption_PMDVFS, totalEnergyConsumption_DVFS, totalEnergyConsumption_PM, MSLtotalEnergyConsumption]; % 用来存储三种方法的耗能
% [~, EnergyConsumptionIndex] = sort(EnergyConsumptionArray);
% if EnergyConsumptionIndex(1) == 4
%     SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 4]; % 调度时长 耗能
% elseif EnergyConsumptionIndex(1) == 3 % 从三种方式中选择耗能最小的作为输出
%     SaveArray = [AFT_PM, totalEnergyConsumption_PM, MSLtotalEnergyConsumption, 3]; % 调度时长 耗能
% elseif EnergyConsumptionIndex(1) == 2
%     SaveArray = [AFT_DVFS, totalEnergyConsumption_DVFS, MSLtotalEnergyConsumption, 2]; % 调度时长 耗能
% elseif EnergyConsumptionIndex(1) == 1
%     SaveArray = [AFT_PMDVFS, totalEnergyConsumption_PMDVFS, MSLtotalEnergyConsumption, 1]; % 调度时长 耗能
% end
for i = 1:NumPro
    eval(strcat('GanteFlag = ScheduleResult_PMDVFS.processor',num2str(i),';'));
    if isempty(GanteFlag) 
        if i==NumPro
            SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
            fprintf(1,'运行失败\n');
        end
        continue
    else
        fprintf(1,'运行成功\n');
        if totalEnergyConsumption_PMDVFS <= MSLtotalEnergyConsumption
            SaveArray = [AFT_PMDVFS, totalEnergyConsumption_PMDVFS, MSLtotalEnergyConsumption, 1]; % 调度时长 耗能
        else
            SaveArray = [AFT_PMDVFS, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
        end
        break
    end
end
end

