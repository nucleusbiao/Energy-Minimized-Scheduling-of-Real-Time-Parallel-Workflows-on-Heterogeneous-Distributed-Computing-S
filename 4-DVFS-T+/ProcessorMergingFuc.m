function [DAG_ProcessorMerging, totalEnergyConsumption, ScheduleResultTOout, failureRate_PM, energySpec_PM, scheduleLength] = ProcessorMergingFuc( DAG, relReq, failureRate, energySpec, MSLscheduleLength)

numProcessor = size(DAG.Wcet, 1); %���漸�е�����֮ǰ�ǳ�ʼ��
numTask = size(DAG.Wcet, 2)-1;
DAG_backup = DAG;
failureRate_backup = failureRate;
energySpec_backup = energySpec;
Turn_Off_Pro_Array = [];
totalEnergyConsumptionArray = [];
for k = 1:numProcessor
    eval(strcat('ScheduleResultTOout.processor',num2str(k),'=[];'));
end

% [MSLscheduleLength,ScheduleResult] = MSLFuc( DAG, relReq, failureRate_backup);
% totalEnergyConsumption = EnergyConsumptionFuc(ScheduleResult, MSLscheduleLength, energySpec_backup);
scheduleLength = MSLscheduleLength;
if MSLscheduleLength == 0
    totalEnergyConsumption = 0;
elseif MSLscheduleLength > DAG.relativeDeadline
    totalEnergyConsumption = 0;
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
            end
        end
        
        if isempty(totalEnergyConsumptionTO) % �����Ѿ��޷��رմ����������
            break
        end
        
        totalEnergyConsumptionTOBU = [];
        for i = 1:size(totalEnergyConsumptionTO,1) % �Ѻ��ܴ�������������
            totalEnergyConsumptionTOBU = [totalEnergyConsumptionTOBU, totalEnergyConsumptionTO(i,2)];
        end
        
        %[c,d] = sort(totalEnergyConsumptionTOBU); % c(1)����С�ܺģ�d(1)�Ǹ���С�ܺ����رյĴ�����
        [c,d] = sort(totalEnergyConsumptionTOBU); % c(1)������ܺģ�d(1)�Ǹ�����ܺ����رյĴ�����
        Turn_Off_Pro = totalEnergyConsumptionTO(d(1),1); % Ӧ�ùرյĴ�������
        totalEnergyConsumption = c(1); % �رմ���������ܺ���
        Turn_Off_Pro_Array = [Turn_Off_Pro_Array, Turn_Off_Pro];
        if numTurnOff == 1
            totalEnergyConsumptionArray = [totalEnergyConsumptionArray, totalEnergyConsumption];
        else
            if totalEnergyConsumption <= totalEnergyConsumptionArray(end)
                totalEnergyConsumptionArray = [totalEnergyConsumptionArray, totalEnergyConsumption];
            else
                break
            end
        end
        
        for i = 1:numTurnOffPro % ��ѡ�еĴ������ҳ���
            m = DAG_backup.Wcet(i,size(DAG.Wcet, 2));
            if m == Turn_Off_Pro
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
    
    totalEnergyConsumption = totalEnergyConsumptionArray(end); % ��Ϊ���
    [scheduleLength,ScheduleResultTOout1] = MSLFuc( DAG_backup, relReq, failureRate_backup); % ��Ϊ���
    Turn_Off_Pro_Array = sort(Turn_Off_Pro_Array); % �����ǰѽ���ı�ű�����
    Total_Pro_Array = [1:1:numProcessor];
    subtract_Array = setdiff(Total_Pro_Array, Turn_Off_Pro_Array) ;
    for k = 1:size(subtract_Array, 2)
        eval(strcat('ScheduleResultTOout.processor',num2str(subtract_Array(k)),'=ScheduleResultTOout1.processor',num2str(k),';')); 
        % DAG_backup.Wcet(subtract_Array(k),:) = DAG_backup.Wcet(k,:); 
    end
end
DAG_ProcessorMerging = DAG_backup;
failureRate_PM = failureRate_backup;
energySpec_PM = energySpec_backup;
end