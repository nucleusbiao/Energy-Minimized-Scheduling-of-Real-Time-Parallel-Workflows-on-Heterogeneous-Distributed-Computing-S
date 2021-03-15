function [ SaveArray, SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate, d)

DAG.arrivalTime = 0;
TaskNum=size(DAG.E, 1);
NumPro = size(DAG.Wcet, 1);
rankUvalueInitial = zeros(1, TaskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % ���ÿ�������rankֵ������-����5.1

DAG = lowerBoundFuc(DAG);   % �������С��AFT
[MSLscheduleLength, MSLScheduleResult] = MSLFuc( DAG, relReq, failureRate);
MSLtotalEnergyConsumption = EnergyConsumptionFuc(MSLScheduleResult, MSLscheduleLength, energySpec);

%[DAG_PM, totalEnergyConsumption_PM, ScheduleResult_PM, failureRate_PM, energySpec_PM, AFT_PM] = ProcessorMergingFuc( DAG, relReq, failureRate, energySpec, MSLscheduleLength); % ֻ�����ںϣ������Ա�
%[DAG_DVFS, totalEnergyConsumption_DVFS, ScheduleResult_DVFS, frequencyScale_DVFS, AFT_DVFS] = DVFS_TasksFuc( DAG, relReq, failureRate, energySpec, d); % ֻ�������ţ������Ա�
tic
[DAG_PMDVFSTask, totalEnergyConsumption_PMDVFSTask, ScheduleResult_PMDVFSTask, failureRate_PMDVFSTask, energySpec_PMDVFSTask, AFT_PMDVFS, frequency_PMDVFSTask] = ...
    ProcessorMerging_DVFSTaskFuc( DAG, relReq, failureRate, energySpec, d, MSLscheduleLength); % ������������ںϣ��Դ�Ϊ����
toc
SLtime = toc;
figure
GanteForDVFSTasks(ScheduleResult_PMDVFSTask,frequency_PMDVFSTask);

% EnergyConsumptionArray = [totalEnergyConsumption_PMDVFSTask, totalEnergyConsumption_DVFS, totalEnergyConsumption_PM, MSLtotalEnergyConsumption]; % �����洢���ַ����ĺ���
% [EnergyConsumptionArray1, EnergyConsumptionIndex] = sort(EnergyConsumptionArray);
% if EnergyConsumptionIndex(1) == 4
%     SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 4]; % ����ʱ�� ����
% elseif EnergyConsumptionIndex(1) == 3 % �����ַ�ʽ��ѡ�������С����Ϊ���
%     SaveArray = [AFT_PM, totalEnergyConsumption_PM, MSLtotalEnergyConsumption, 3]; % ����ʱ�� ����
% elseif EnergyConsumptionIndex(1) == 2
%     SaveArray = [AFT_DVFS, totalEnergyConsumption_DVFS, MSLtotalEnergyConsumption, 2]; % ����ʱ�� ����
% elseif EnergyConsumptionIndex(1) == 1
%     SaveArray = [AFT_PMDVFS, totalEnergyConsumption_PMDVFSTask, MSLtotalEnergyConsumption, 1]; % ����ʱ�� ����
% end

for i = 1:NumPro %�ѵ��Ƚ�����ڵĴ������Ϳ�ʼʱ�䱣������
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

for i = 1:NumPro %���տ�ʼ����ʵ���ʱ�������
    eval(strcat('GanteFlag = ScheduleResult_PMDVFSTask.processor',num2str(i),';'));
    if isempty(GanteFlag)
        if i==NumPro
            SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
            fprintf(1,'����ʧ��\n');
        end
        continue
    else
        fprintf(1,'���гɹ�\n');
        if totalEnergyConsumption_PMDVFSTask <= MSLtotalEnergyConsumption
            SaveArray = [AFT_PMDVFS, totalEnergyConsumption_PMDVFSTask, MSLtotalEnergyConsumption, 1]; % ����ʱ�� ����
        else
            SaveArray = [AFT_PMDVFS, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
        end
        break
    end
end
end

