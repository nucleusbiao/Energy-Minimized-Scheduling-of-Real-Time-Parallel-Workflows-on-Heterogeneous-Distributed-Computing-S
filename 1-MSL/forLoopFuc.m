function [ SaveArray, SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate)
%% ���ȼ�����
DAG.arrivalTime = 0;
TaskNum=size(DAG.E, 1);
NumPro = size(DAG.Wcet, 1);
rankUvalueInitial = zeros(1, TaskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % ���ÿ�������rankֵ������

%% ��������������
tic
[MSLscheduleLength, MSLScheduleResult] = MSLFuc( DAG, relReq, failureRate);
MSLtotalEnergyConsumption = EnergyConsumptionFuc(MSLScheduleResult, MSLscheduleLength, energySpec);
toc
SLtime = toc;

frequencyArrayFinal = ones(1,TaskNum);
figure;
GanteForDVFSTasks(MSLScheduleResult, frequencyArrayFinal);
SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption];