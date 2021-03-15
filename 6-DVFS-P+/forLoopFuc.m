function [ SaveArray, SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate)
%% ����5.1�е����ȼ�����
DAG.arrivalTime = 0;
TaskNum = size(DAG.Wcet, 2) - 1;
NumPro = size(DAG.Wcet, 1);
rankUvalueInitial = zeros(1, TaskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % ���ÿ�������rankֵ������

%% ��������������
d = 3;   %����ʧ���ʶԵ�ѹ���ŵ����г̶�
[MSLscheduleLength, MSLScheduleResult] = MSLFuc( DAG, relReq, failureRate);
MSLtotalEnergyConsumption = EnergyConsumptionFuc(MSLScheduleResult, MSLscheduleLength, energySpec);

% [DAG_PM, totalEnergyConsumption_PM, ScheduleResult_PM, failureRate_PM, energySpec_PM, AFT_PM] = ProcessorMergingFuc( DAG, relReq, failureRate, energySpec, MSLscheduleLength); % ֻ�����ںϣ������Ա�
% [DAG_DVFS, totalEnergyConsumption_DVFS, ScheduleResult_DVFS, frequencyScale_DVFS, AFT_DVFS] = DVFS_ProcessorFuc( DAG, relReq, failureRate, energySpec, d, NumPro); % ֻ�������ţ������Ա�
tic
[DAG_PMDVFS, totalEnergyConsumption_PMDVFS, ScheduleResult_PMDVFS, failureRate_PMDVFS, energySpec_PMDVFS, AFT_PMDVFS, frequencyScale_PMDVFS] = ...
    ProcessorMerging_DVFSFuc( DAG, relReq, failureRate, energySpec, d, MSLscheduleLength); % ������������ںϣ��Դ�Ϊ����
toc
SLtime = toc;
figure
GanteForDVFSPro(ScheduleResult_PMDVFS, frequencyScale_PMDVFS);

% EnergyConsumptionArray = [totalEnergyConsumption_PMDVFS, totalEnergyConsumption_DVFS, totalEnergyConsumption_PM, MSLtotalEnergyConsumption]; % �����洢���ַ����ĺ���
% [~, EnergyConsumptionIndex] = sort(EnergyConsumptionArray);
% if EnergyConsumptionIndex(1) == 4
%     SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 4]; % ����ʱ�� ����
% elseif EnergyConsumptionIndex(1) == 3 % �����ַ�ʽ��ѡ�������С����Ϊ���
%     SaveArray = [AFT_PM, totalEnergyConsumption_PM, MSLtotalEnergyConsumption, 3]; % ����ʱ�� ����
% elseif EnergyConsumptionIndex(1) == 2
%     SaveArray = [AFT_DVFS, totalEnergyConsumption_DVFS, MSLtotalEnergyConsumption, 2]; % ����ʱ�� ����
% elseif EnergyConsumptionIndex(1) == 1
%     SaveArray = [AFT_PMDVFS, totalEnergyConsumption_PMDVFS, MSLtotalEnergyConsumption, 1]; % ����ʱ�� ����
% end
for i = 1:NumPro
    eval(strcat('GanteFlag = ScheduleResult_PMDVFS.processor',num2str(i),';'));
    if isempty(GanteFlag) 
        if i==NumPro
            SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
            fprintf(1,'����ʧ��\n');
        end
        continue
    else
        fprintf(1,'���гɹ�\n');
        if totalEnergyConsumption_PMDVFS <= MSLtotalEnergyConsumption
            SaveArray = [AFT_PMDVFS, totalEnergyConsumption_PMDVFS, MSLtotalEnergyConsumption, 1]; % ����ʱ�� ����
        else
            SaveArray = [AFT_PMDVFS, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
        end
        break
    end
end
end

