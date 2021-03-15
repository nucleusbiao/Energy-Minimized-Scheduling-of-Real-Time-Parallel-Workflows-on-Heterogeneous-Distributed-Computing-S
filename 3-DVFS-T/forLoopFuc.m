function [ SaveArray , SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate, d)
%% ����5.1�е����ȼ�����
DAG.arrivalTime = 0;
TaskNum=size(DAG.E, 2);
NumPro=size(DAG.Wcet, 1); % ����������
rankUvalueInitial = zeros(1, TaskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % ���ÿ�������rankֵ������
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
%% ��������������
DAG = lowerBoundFuc(DAG);   % �������С��AFT

tic
[MSLscheduleLength, MSLScheduleResult, relPerTask] = MSLFuc( DAG, relReq, failureRate);
MSLFreq = ones(1, TaskNum);
% figure
% GanteForDVFSTasks(MSLScheduleResult, MSLFreq);

relSum = 1;
for i=1:size(relPerTask,2)
    relSum = relSum*relPerTask(i);
end
MSLtotalEnergyConsumption = EnergyConsumptionFuc(MSLScheduleResult, MSLscheduleLength, energySpec);
toc
SLtime = toc;

[DAG_DVFS, TasktotalEnergyConsumption, scheduleOut, frequencyArrayFinal, TaskscheduleLength] = DVFS_TasksFuc( DAG, relReq, failureRate, energySpec, d, MSLscheduleLength, MSLScheduleResult);

[a,~]=sort(frequencyArrayFinal,'descend');
figure
GanteForDVFSTasks(scheduleOut, frequencyArrayFinal);

if a(1)>1
    % fprintf(1,'�޷�����\n');
    SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
else
    for i = 1:NumPro
        eval(strcat('GanteFlag = scheduleOut.processor',num2str(i),';'));
        if isempty(GanteFlag)
            if i==NumPro
                % fprintf(1,'schedule Failed\n');
                SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
                fprintf(1,'����ʧ��\n');
            end
            continue
        else
            fprintf(1,'���гɹ�\n');
            if TasktotalEnergyConsumption <= MSLtotalEnergyConsumption
                SaveArray = [TaskscheduleLength, TasktotalEnergyConsumption, MSLtotalEnergyConsumption, 1]; % ����ʱ�� ����
            else
                SaveArray = [TaskscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
            end
            break
        end
    end
end
end