function [DAG_PMDVFSTask, totalEnergyConsumption_PMDVFSTask, ScheduleResult_PMDVFSTask, failureRate_PMDVFSTask, ...
    energySpec_PMDVFSTask, scheduleLength, frequency_PMDVFSTask] = ProcessorMerging_DVFSTaskFuc( DAG, relReq, failureRate, energySpec,d, MSLscheduleLength)

numProcessor = size(DAG.Wcet, 1); %���漸�е�����֮ǰ�ǳ�ʼ��
numTask = size(DAG.Wcet, 2)-1;
frequency_PMDVFSTask = ones(1, numTask);
DAG_backup = DAG;
failureRate_backup = failureRate;
energySpec_backup = energySpec;
Turn_Off_Pro_Array = [];
totalEnergyConsumptionArray = [];
for k = 1:numProcessor
    eval(strcat('ScheduleResult_PMDVFSTask.processor',num2str(k),'=[];'));
end

% [MSLscheduleLength,ScheduleResult] = MSLFuc( DAG, relReq, failureRate_backup);
% totalEnergyConsumption_PMDVFSTask = EnergyConsumptionFuc(ScheduleResult, MSLscheduleLength, energySpec_backup);
scheduleLength = MSLscheduleLength;
if MSLscheduleLength == 0
    totalEnergyConsumption_PMDVFSTask = 0;
elseif MSLscheduleLength > DAG.relativeDeadline
    totalEnergyConsumption_PMDVFSTask = 0;
    % fprintf(1,'ProcessorMerging������17�������޷��������ʱ��\n\n');
else
    for numTurnOff = 1:numProcessor-1 % �ɹرյ�����
        numTurnOffPro = size(DAG_backup.Wcet, 1);
        DAG_backup1 = DAG_backup;
        totalEnergyConsumptionTO = [];
        
        for i = 1:numTurnOffPro % ���Թر�ĳһ������
            Turn_Off_Pro = DAG_backup.Wcet(i,numTask+1); % ���رյĴ�������
            DAG_backup1.Wcet = [DAG_backup.Wcet(1:i-1,:); DAG_backup.Wcet(i+1:end,:)];
            rankUvalueInitial = zeros(1, numTask);
            DAG_backup1 = upwardRankFuc(DAG_backup1, rankUvalueInitial);  % �������ÿ�������rankֵ������
            failureRate_backup1 = [failureRate_backup(1,1:i-1), failureRate_backup(1,i+1:end)];
            energySpec_backup1 = [energySpec_backup(1:i-1,:); energySpec_backup(i+1:end,:)];
            [AFTForiTaskTO1,ScheduleResultTO1] = MSLFuc( DAG_backup1, relReq, failureRate_backup1);
            
            if AFTForiTaskTO1 == 0
                continue
            elseif AFTForiTaskTO1 > DAG.relativeDeadline
                continue
            else
                AFTForiTaskTO = AFTForiTaskTO1;
                ScheduleResultTO = ScheduleResultTO1;
                EnergyConsumptionTO = EnergyConsumptionFuc(ScheduleResultTO, AFTForiTaskTO, energySpec_backup1); 
                totalEnergyConsumptionTO = [totalEnergyConsumptionTO; Turn_Off_Pro, EnergyConsumptionTO]; % ���ɹرյĴ������͹رպ�ĺ��ܴ�����
%                 [DAG_DVFS_Task, totalEnergyConsumption_DVFSTask, ScheduleResult_DVFSTask, frequencyArrayFinal, AFT_DVFSTask] = ...
%                     DVFS_TasksFuc( DAG_backup1, relReq, failureRate_backup1, energySpec_backup1, d);
%                 totalEnergyConsumptionTO = [totalEnergyConsumptionTO; Turn_Off_Pro, totalEnergyConsumption_DVFSTask]; % ���ɹرյĴ������͹رպ�ĺ��ܴ�����
            end
        end
        
        if isempty(totalEnergyConsumptionTO) % �����Ѿ��޷��رմ����������
            break
        end
        
        totalEnergyConsumptionTOBU = [];
        for i = 1:size(totalEnergyConsumptionTO,1) % �Ѻ��ܴ�������������
            totalEnergyConsumptionTOBU = [totalEnergyConsumptionTOBU, totalEnergyConsumptionTO(i,2)];
        end
        
        [c,e] = sort(totalEnergyConsumptionTOBU); % c(1)������ܺģ�d(1)�Ǹ�����ܺ����رյĴ�����
        Turn_Off_Pro = totalEnergyConsumptionTO(e(1),1); % Ӧ�ùرյĴ�������
        totalEnergyConsumption_PMDVFSTask = c(1); % �رմ���������ܺ���
        Turn_Off_Pro_Array = [Turn_Off_Pro_Array, Turn_Off_Pro];
        if numTurnOff == 1
            totalEnergyConsumptionArray = [totalEnergyConsumptionArray, c(1)];
        else
            if c(1) <= totalEnergyConsumptionArray(end)
                totalEnergyConsumptionArray = [totalEnergyConsumptionArray, c(1)];
            else % �ٹر�Ҳ���ܼ����ܺ���
                Turn_Off_Pro_Array = Turn_Off_Pro_Array(1:end-1);
                break
            end
        end
        
        for i = 1:numTurnOffPro % ��ѡ�еĴ������ҳ���
            m = DAG_backup.Wcet(i,size(DAG.Wcet, 2));
            if m == Turn_Off_Pro
                break
            end
        end
        DAG_backup.Wcet = [DAG_backup.Wcet(1:i-1,:); DAG_backup.Wcet(i+1:end,:)];% ��ѡ�еĴ�����ɾ��
        rankUvalueInitial = zeros(1, numTask);
        DAG_backup = upwardRankFuc(DAG_backup, rankUvalueInitial);  % �������ÿ�������rankֵ������
        failureRate_backup = [failureRate_backup(1,1:i-1), failureRate_backup(1,i+1:end)];
        energySpec_backup = [energySpec_backup(1:i-1,:); energySpec_backup(i+1:end,:)];
        
    end % end for numTurnOff = 1:numProcessor % �ɹرյ�����
    
    [DAG_backup, totalEnergyConsumption_PMDVFSTask, ScheduleResultOut, frequency_PMDVFSTask, scheduleLength] = DVFS_TasksFuc( DAG_backup, relReq, failureRate_backup, energySpec_backup, d); % ��Ϊ���
    Turn_Off_Pro_Array = sort(Turn_Off_Pro_Array); % �����ǰѽ���ı�ű�����
    Total_Pro_Array = [1:1:numProcessor];
    subtract_Array = setdiff(Total_Pro_Array, Turn_Off_Pro_Array) ;
    for k = 1:size(subtract_Array, 2)
        eval(strcat('ScheduleResult_PMDVFSTask.processor',num2str(subtract_Array(k)),'=ScheduleResultOut.processor',num2str(k),';')); 
    end
end
DAG_PMDVFSTask = DAG_backup;
failureRate_PMDVFSTask = failureRate_backup;
energySpec_PMDVFSTask = energySpec_backup;
end