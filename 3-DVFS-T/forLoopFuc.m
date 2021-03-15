function [ SaveArray , SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate, d)
%% 论文5.1中的优先级排序
DAG.arrivalTime = 0;
TaskNum=size(DAG.E, 2);
NumPro=size(DAG.Wcet, 1); % 处理器数量
rankUvalueInitial = zeros(1, TaskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % 算出每个任务的rank值并排序
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
%% 计算总能量消耗
DAG = lowerBoundFuc(DAG);   % 算出的最小的AFT

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
    % fprintf(1,'无法缩放\n');
    SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
else
    for i = 1:NumPro
        eval(strcat('GanteFlag = scheduleOut.processor',num2str(i),';'));
        if isempty(GanteFlag)
            if i==NumPro
                % fprintf(1,'schedule Failed\n');
                SaveArray = [MSLscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
                fprintf(1,'运行失败\n');
            end
            continue
        else
            fprintf(1,'运行成功\n');
            if TasktotalEnergyConsumption <= MSLtotalEnergyConsumption
                SaveArray = [TaskscheduleLength, TasktotalEnergyConsumption, MSLtotalEnergyConsumption, 1]; % 调度时长 耗能
            else
                SaveArray = [TaskscheduleLength, MSLtotalEnergyConsumption, MSLtotalEnergyConsumption, 2];
            end
            break
        end
    end
end
end