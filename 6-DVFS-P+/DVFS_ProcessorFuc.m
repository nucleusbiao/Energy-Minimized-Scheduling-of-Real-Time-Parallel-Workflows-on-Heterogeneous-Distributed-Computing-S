function [DAG_DVFS, totalEnergyConsumption, ScheduleResultProi1, frequencyScale2, AFTForiTaskProi] = DVFS_ProcessorFuc( DAG, relReq, failureRate, energySpec, d, NumPro)

numProcessor = size(DAG.Wcet, 1); %下面几行到空行之前是初始化
numTask = size(DAG.E, 1);
relProPM = DAG.Wcet(:,end); % 把Processor_Merging后未关闭的处理器找出来
frequencyScale(1:NumPro) = 1;
frequencyScale2 = frequencyScale;
DAG_backup = DAG;
DAG_backup1 = DAG;
failureRate_backup = failureRate;
for i=1:NumPro
    eval(strcat('ScheduleResultProi1.processor',num2str(i),'=[];'));
end
[AFTForiTask,ScheduleResult] = MSLFuc( DAG_backup, relReq, failureRate_backup);
AFTForiTask_backup = AFTForiTask;
AFTForiTaskProi = AFTForiTask;
% totalEnergyConsumption_backup = EnergyConsumptionFreqFuc(ScheduleResult, AFTForiTask_backup, energySpec, frequencyScale); %

imax = size(DAG.Wcet , 1); % 将schedule的调度结果变为真正的处理器
for i = 1:imax
    eval(strcat('ScheduleResult_backup.processor',num2str(relProPM(i)),'=ScheduleResult.processor',num2str(i),';'))
end
ASFlag = [0,0]; % 加减的标志

if AFTForiTask_backup == 0
    totalEnergyConsumption_backup = 0;
    % fprintf(1,'无法满足可靠性而无法调度\n\n');
elseif AFTForiTask_backup > DAG_backup.relativeDeadline
    totalEnergyConsumption_backup = 0;
    % fprintf(1,'DVFS函数中20行左右无法满足截至时间\n\n');
else
     % 进行第一步，整体缩放
    fx1 = AFTForiTask_backup / DAG_backup.relativeDeadline; % 以下四行是取大的两位小数
    fx2 = fx1 * 100;
    fx2 = ceil(fx2);
    fx3 = fx2 / 100;
    fx_Choiced = fx3;
    while 1
        for numPro = 1:numProcessor % 求出每个处理器在新频率下的失败率
            relFreqRatio = 10^(d * (energySpec(numPro,6) - fx_Choiced) / (energySpec(numPro,6) - energySpec(numPro,5))); % DVFS的可靠性中系数一部分
            failureRate_backup(numPro) = failureRate(numPro) * relFreqRatio;
        end
        DAG_backup.Wcet = [DAG.Wcet(1:end, 1:end-1) / fx_Choiced, DAG.Wcet(1:end,end)]; % 求出每个处理器在新频率下的执行时间
        rankUvalueInitial = zeros(1, numTask);
        DAG_backup = upwardRankFuc(DAG_backup, rankUvalueInitial);  % 算出每个任务的rank值并排序
        [AFTForiTaskPro,ScheduleResultPro] = MSLFuc( DAG_backup, relReq, failureRate_backup);
%         frequencyScale1(1:3)=fx_Choiced;
%         totalEnergyConsumption_backup = EnergyConsumptionFreqFuc(ScheduleResultPro, AFTForiTaskPro, energySpec, frequencyScale1); 
        if AFTForiTaskPro == 0
            fx_Choiced = fx_Choiced + 0.01;
            if ASFlag(2) == 1
                ASFlag(1) = 2;
            else
                ASFlag(1) = 1;
            end
        elseif AFTForiTaskPro > DAG_backup.relativeDeadline
            fx_Choiced = fx_Choiced + 0.01;
            if ASFlag(2) == 1
                ASFlag(1) = 2;
            else
                ASFlag(1) = 1;
            end
        else
            fx_Choiced = fx_Choiced - 0.01;
            if ASFlag(1) == 1
                ASFlag(2) = 2;
            else
                ASFlag(2) = 1;
            end
        end
        if (ASFlag(1)>0) && (ASFlag(2)>0)
            if ASFlag(2) > ASFlag(1)
                fx_Choiced = fx_Choiced + 0.01;
                frequencyScale1 = frequencyScale * fx_Choiced;
                break
            else
                frequencyScale1 = frequencyScale * fx_Choiced;
                break
            end
        end
    end
    
     % 进行第二步，每个处理器单独再缩放
    for numPro = 1:numProcessor 
        fx_Choicedi = fx_Choiced;
        decimal = 0.01; % 决定频率每次的变化量
        stopFlagPMi = 0;
        while 1
            fx_Choicedi = fx_Choicedi - decimal;
            relFreqRatio = 10^(d * (energySpec(numPro,6) - fx_Choicedi) / (energySpec(numPro,6) - energySpec(numPro,5)));
            failureRate_backup(numPro) = failureRate(numPro) * relFreqRatio;
            DAG_backup.Wcet(numPro,:) = [DAG.Wcet(numPro,1:end-1) / fx_Choicedi, DAG.Wcet(numPro,end)];
            rankUvalueInitial = zeros(1, numTask);
            DAG_backup = upwardRankFuc(DAG_backup, rankUvalueInitial);  % 算出每个任务的rank值并排序
            [AFTForiTaskProi,ScheduleResultProi] = MSLFuc( DAG_backup, relReq, failureRate_backup);
            
            if AFTForiTaskProi == 0 % 判断是否满足调度时长的要求
                stopFlagPMi = 1;
            elseif AFTForiTaskProi > DAG_backup1.relativeDeadline
                stopFlagPMi = 1;
            end
            
            % 下面是对于要结束的情况进行的数据计算采集
            if fx_Choicedi < energySpec(numPro,5) % 小于最小频率时要让其选择最小频率
                fx_Choicedi = energySpec(numPro,5);
                frequencyScale1(numPro) = frequencyScale(numPro) * fx_Choicedi;
                relFreqRatio = 10^(d * (energySpec(numPro,6) - fx_Choicedi) / (energySpec(numPro,6) - energySpec(numPro,5)));
                failureRate_backup(numPro) = failureRate(numPro) * relFreqRatio;
                DAG_backup.Wcet(numPro,:) = [DAG.Wcet(numPro,1:end-1) / fx_Choicedi, DAG.Wcet(numPro,end)];
                rankUvalueInitial = zeros(1, numTask);
                DAG_backup = upwardRankFuc(DAG_backup, rankUvalueInitial);  % 算出每个任务的rank值并排序
                [AFTForiTaskProi,ScheduleResultProi] = MSLFuc( DAG_backup, relReq, failureRate_backup);
                totalEnergyConsumption_backup = EnergyConsumptionFreqFuc(ScheduleResultProi, AFTForiTaskProi, energySpec, frequencyScale1);
                frequencyScale2(1:NumPro) = 0;
                for i = 1:imax
                    eval(strcat('ScheduleResultProi1.processor',num2str(relProPM(i)),'=ScheduleResultProi.processor',num2str(i),';'))
                    frequencyScale2(relProPM(i)) = frequencyScale1(i);
                end
                break
            end
            if stopFlagPMi == 1 % 不满足AFT要求时要返回上一个频率
                fx_Choicedi = fx_Choicedi + decimal;
                frequencyScale1(numPro) = frequencyScale(numPro) * fx_Choicedi;
                relFreqRatio = 10^(d * (energySpec(numPro,6) - fx_Choicedi) / (energySpec(numPro,6) - energySpec(numPro,5)));
                failureRate_backup(numPro) = failureRate(numPro) * relFreqRatio;
                DAG_backup.Wcet(numPro,:) = [DAG.Wcet(numPro,1:end-1) / fx_Choicedi, DAG.Wcet(numPro,end)];
                rankUvalueInitial = zeros(1, numTask);
                DAG_backup = upwardRankFuc(DAG_backup, rankUvalueInitial);  % 算出每个任务的rank值并排序
                [AFTForiTaskProi,ScheduleResultProi] = MSLFuc( DAG_backup, relReq, failureRate_backup);
                totalEnergyConsumption_backup = EnergyConsumptionFreqFuc(ScheduleResultProi, AFTForiTaskProi, energySpec, frequencyScale1);
                frequencyScale2(1:NumPro) = 0;
                for i = 1:imax
                    eval(strcat('ScheduleResultProi1.processor',num2str(relProPM(i)),'=ScheduleResultProi.processor',num2str(i),';'))
                    frequencyScale2(relProPM(i)) = frequencyScale1(i);
                end
                break
            end
        end
    end
end

DAG_DVFS = DAG_backup;
totalEnergyConsumption = totalEnergyConsumption_backup;
end

