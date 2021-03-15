function [ SaveArray, SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate)
%% ����5.1�е����ȼ�����
DAG.arrivalTime = 0;
TaskNum = size(DAG.Wcet, 2)-1;
NumPro = size(DAG.Wcet, 1);
rankUvalueInitial = zeros(1, TaskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % ���ÿ�������rankֵ������
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
%% ��������������
DAG = lowerBoundFuc(DAG);   % �������С��AFT
d = 3;   %����ʧ���ʶԵ�ѹ���ŵ����г̶�
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
            fprintf(1,'����ʧ��\n');
        end
        continue
    else
        fprintf(1,'���гɹ�\n');
        if PMtotalEnergyConsumption <= MSLtotalEnergyConsumption
            SaveArray = [ProscheduleLength, PMtotalEnergyConsumption, MSLtotalEnergyConsumption, 1]; % ����ʱ�� ����
        else
            SaveArray = [ProscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
        end
        break
    end
end
end