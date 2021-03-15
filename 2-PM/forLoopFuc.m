function [ SaveArray, SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate)
%% 优先级排序
DAG.arrivalTime = 0;
TaskNum=size(DAG.E, 1);
NumPro = size(DAG.Wcet, 1);
rankUvalueInitial = zeros(1, TaskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % 算出每个任务的rank值并排序

%% 计算总能量消耗
[MSLscheduleLength, MSLScheduleResult] = MSLFuc( DAG, relReq, failureRate);
MSLtotalEnergyConsumption = EnergyConsumptionFuc(MSLScheduleResult, MSLscheduleLength, energySpec);
tic
[DAG_ProcessorMerging, PMtotalEnergyConsumption, PMScheduleResultT, PMscheduleLength] = ProcessorMergingFuc( DAG, relReq, failureRate, energySpec, MSLscheduleLength);
toc
SLtime = toc;

frequencyArrayFinal = ones(1,TaskNum);
figure;
GanteForDVFSTasks(PMScheduleResultT, frequencyArrayFinal);
for i = 1:NumPro
    eval(strcat('GanteFlag = PMScheduleResultT.processor',num2str(i),';'));
    if isempty(GanteFlag) 
        if i==NumPro
            SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
            fprintf(1,'运行失败\n');
        end
        continue
    else
        fprintf(1,'运行成功\n');
        if PMtotalEnergyConsumption <= MSLtotalEnergyConsumption
            SaveArray = [PMscheduleLength, PMtotalEnergyConsumption, MSLtotalEnergyConsumption, 1]; % 调度时长 耗能
        else
            SaveArray = [PMscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
        end
        break
    end
end