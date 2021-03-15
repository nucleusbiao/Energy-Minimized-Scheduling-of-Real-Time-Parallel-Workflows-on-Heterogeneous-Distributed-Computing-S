function [DAG_PMDVFS, totalEnergyConsumption_PMDVFS, ScheduleResult_PMDVFS, failureRate_PMDVFS, energySpec_PMDVFS, ...
    scheduleLength, frequencyScale_PMDVFS] = ProcessorMerging_DVFSFuc( DAG, relReq, failureRate, energySpec, d, MSLscheduleLength)

numProcessor = size(DAG.Wcet, 1); %下面几行到空行之前是初始化
numTask = size(DAG.Wcet, 2)-1;
DAG_backup = DAG;
failureRate_backup = failureRate;
energySpec_backup = energySpec;
Turn_Off_Pro_Array = [];
totalEnergyConsumptionArray = [];
frequencyScale_PMDVFS = ones(1, numProcessor);
for k = 1:numProcessor
    eval(strcat('ScheduleResult_PMDVFS.processor',num2str(k),'=[];'));
end

% [MSLscheduleLength,ScheduleResult] = MSLFuc( DAG, relReq, failureRate_backup);
% totalEnergyConsumption_PMDVFS = EnergyConsumptionFuc(ScheduleResult, MSLscheduleLength, energySpec_backup);
scheduleLength = MSLscheduleLength;
if MSLscheduleLength == 0
    totalEnergyConsumption_PMDVFS = 0;
elseif MSLscheduleLength > DAG.relativeDeadline
    totalEnergyConsumption_PMDVFS = 0;
    % fprintf(1,'ProcessorMerging函数中17行左右无法满足截至时间\n\n');
else
    for numTurnOff = 1:numProcessor-1 % 可关闭的数量
        numTurnOffPro = size(DAG_backup.Wcet, 1);
        DAG_backup1 = DAG_backup;
        totalEnergyConsumptionTO = [];
        
        for i = 1:numTurnOffPro % 尝试关闭某一处理器
            Turn_Off_Pro = DAG_backup.Wcet(i,numTask+1); % 将关闭的处理器号
            DAG_backup1.Wcet = [DAG_backup.Wcet(1:i-1,:); DAG_backup.Wcet(i+1:end,:)];
            rankUvalueInitial = zeros(1, numTask);
            DAG_backup1 = upwardRankFuc(DAG_backup1, rankUvalueInitial);  % 重新算出每个任务的rank值并排序
            failureRate_backup1 = [failureRate_backup(1,1:i-1), failureRate_backup(1,i+1:end)];
            energySpec_backup1 = [energySpec_backup(1:i-1,:); energySpec_backup(i+1:end,:)];
            [AFTForiTaskTO1,ScheduleResultTO1] = MSLFuc( DAG_backup1, relReq, failureRate_backup1);
            
            if AFTForiTaskTO1 == 0
                continue
            elseif AFTForiTaskTO1 > DAG.relativeDeadline
                continue
            else
%                 [DAG_DVFS, totalEnergyConsumption_DVFS, ScheduleResult_DVFS, frequencyScale_DVFS, AFT_DVFS] = ...
%                     DVFS_ProcessorFuc( DAG_backup1, relReq, failureRate_backup1, energySpec_backup1, d, numProcessor);
%                 totalEnergyConsumptionTO = [totalEnergyConsumptionTO; Turn_Off_Pro, totalEnergyConsumption_DVFS]; % 将可关闭的处理器和关闭后的耗能存起来
                AFTForiTaskTO = AFTForiTaskTO1;
                ScheduleResultTO = ScheduleResultTO1;
                EnergyConsumptionTO = EnergyConsumptionFuc(ScheduleResultTO, AFTForiTaskTO, energySpec_backup1); 
                totalEnergyConsumptionTO = [totalEnergyConsumptionTO; Turn_Off_Pro, EnergyConsumptionTO]; % 将可关闭的处理器和关闭后的耗能存起来
            end
        end
        
        if isempty(totalEnergyConsumptionTO) % 代表已经无法关闭处理器的情况
            break
        end
        
        totalEnergyConsumptionTOBU = [];
        for i = 1:size(totalEnergyConsumptionTO,1) % 把耗能存起来便于排序
            totalEnergyConsumptionTOBU = [totalEnergyConsumptionTOBU, totalEnergyConsumptionTO(i,2)];
        end
        
        %[c,d] = sort(totalEnergyConsumptionTOBU); % c(1)是最小能耗，d(1)是该最小能耗所关闭的处理器
        [c,e] = sort(totalEnergyConsumptionTOBU); % c(1)是最大能耗，d(1)是该最大能耗所关闭的处理器
        Turn_Off_Pro = totalEnergyConsumptionTO(e(1),1); % 应该关闭的处理器号
        Turn_Off_Pro_Array = [Turn_Off_Pro_Array, Turn_Off_Pro];
        if numTurnOff == 1
            totalEnergyConsumptionArray = [totalEnergyConsumptionArray, c(1)];
        else
            if c(1) <= totalEnergyConsumptionArray(end)
                totalEnergyConsumptionArray = [totalEnergyConsumptionArray, c(1)];
            else % 再关闭也不能减少能耗了
                Turn_Off_Pro_Array = Turn_Off_Pro_Array(1:end-1);
                break
            end
        end
        
        for i = 1:numTurnOffPro % 将选中的处理器找出来
            m = DAG_backup.Wcet(i, end);
            if m == Turn_Off_Pro
                break
            end
        end
        DAG_backup.Wcet = [DAG_backup.Wcet(1:i-1,:); DAG_backup.Wcet(i+1:end,:)];% 将选中的处理器删掉
        rankUvalueInitial = zeros(1, numTask);
        DAG_backup = upwardRankFuc(DAG_backup, rankUvalueInitial);  % 重新算出每个任务的rank值并排序
        failureRate_backup = [failureRate_backup(1,1:i-1), failureRate_backup(1,i+1:end)];
        energySpec_backup = [energySpec_backup(1:i-1,:); energySpec_backup(i+1:end,:)];
        
    end % end for numTurnOff = 1:numProcessor % 可关闭的数量
    
    [DAG_backup, totalEnergyConsumption_PMDVFS, ScheduleResult_PMDVFS, frequencyScale_PMDVFS, scheduleLength] = DVFS_ProcessorFuc( DAG_backup, relReq, failureRate_backup, energySpec_backup, d, numProcessor);
%     Turn_Off_Pro_Array = sort(Turn_Off_Pro_Array); % 下面是把结果的编号变正常,在此不需要，因为运行完上式已经正常了
%     Total_Pro_Array = [1:1:numProcessor];
%     subtract_Array = setdiff(Total_Pro_Array, Turn_Off_Pro_Array) ;
%     for k = 1:size(subtract_Array, 2)
%         eval(strcat('ScheduleResult_PMDVFS.processor',num2str(subtract_Array(k)),'=ScheduleResult_DVFS.processor',num2str(k),';')); 
%         % DAG_backup.Wcet(subtract_Array(k),:) = DAG_backup.Wcet(k,:); 
%     end
end
DAG_PMDVFS = DAG_backup;
failureRate_PMDVFS = failureRate_backup;
energySpec_PMDVFS = energySpec_backup;
end