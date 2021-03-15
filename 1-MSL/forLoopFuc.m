function [ SaveArray, SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate)
%% 优先级排序
DAG.arrivalTime = 0;
TaskNum=size(DAG.E, 1);
NumPro = size(DAG.Wcet, 1);
rankUvalueInitial = zeros(1, TaskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % 算出每个任务的rank值并排序

%% 计算总能量消耗
tic
[MSLscheduleLength, MSLScheduleResult] = MSLFuc( DAG, relReq, failureRate);
MSLtotalEnergyConsumption = EnergyConsumptionFuc(MSLScheduleResult, MSLscheduleLength, energySpec);
toc
SLtime = toc;

frequencyArrayFinal = ones(1,TaskNum);
figure;
GanteForDVFSTasks(MSLScheduleResult, frequencyArrayFinal);
SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption];