function [ SaveArray, SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate)
%% ���ȼ�����
DAG.arrivalTime = 0;
TaskNum=size(DAG.E, 1);
NumPro = size(DAG.Wcet, 1);
rankUvalueInitial = zeros(1, TaskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % ���ÿ�������rankֵ������

%% ��������������
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
            fprintf(1,'����ʧ��\n');
        end
        continue
    else
        fprintf(1,'���гɹ�\n');
        if PMtotalEnergyConsumption <= MSLtotalEnergyConsumption
            SaveArray = [PMscheduleLength, PMtotalEnergyConsumption, MSLtotalEnergyConsumption, 1]; % ����ʱ�� ����
        else
            SaveArray = [PMscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
        end
        break
    end
end