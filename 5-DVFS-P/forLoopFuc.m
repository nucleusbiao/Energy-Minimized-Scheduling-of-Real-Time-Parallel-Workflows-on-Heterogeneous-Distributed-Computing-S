function [ SaveArray, SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate)
%% 论文5.1中的优先级排序
DAG.arrivalTime = 0;
TaskNum = size(DAG.Wcet, 2)-1;
NumPro = size(DAG.Wcet, 1);
rankUvalueInitial = zeros(1, TaskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % 算出每个任务的rank值并排序
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
%% 计算总能量消耗
DAG = lowerBoundFuc(DAG);   % 算出的最小的AFT
d = 3;   %代表失败率对电压缩放的敏感程度
[MSLscheduleLength, MSLScheduleResult] = MSLFuc( DAG, relReq, failureRate);
MSLtotalEnergyConsumption = EnergyConsumptionFuc(MSLScheduleResult, MSLscheduleLength, energySpec);
tic
[DAG_DVFS, PMtotalEnergyConsumption, ScheduleResultProi, frequencyScale, ProscheduleLength] = DVFS_ProcessorFuc( DAG, relReq, failureRate, energySpec, d, MSLscheduleLength);
toc
SLtime = toc;
figure
GanteForDVFSPro(ScheduleResultProi, frequencyScale);
for i = 1:NumPro
    eval(strcat('GanteFlag = ScheduleResultProi.processor',num2str(i),';'));
    if isempty(GanteFlag) 
        if i==NumPro
            SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
            fprintf(1,'运行失败\n');
        end
        continue
    else
        fprintf(1,'运行成功\n');
        if PMtotalEnergyConsumption <= MSLtotalEnergyConsumption
            SaveArray = [ProscheduleLength, PMtotalEnergyConsumption, MSLtotalEnergyConsumption, 1]; % 调度时长 耗能
        else
            SaveArray = [ProscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
        end
        break
    end
end
end