function [makeSpan, scheduleOut, frequencyArrayFinal] = scheduleFunctionDVFSFuc(schedule, F, ...
    ratioRel, reliPerTask, relReq, failureRate, energySpec, d)

numECU = size(F.Wcet, 1);
numTask = size(F.Wcet, 2)-1;

frequencyArrayFinal = [];

% beamSize和 beamSearch都是 1
beamSearch = 1;
scheduleBack_up = schedule;
relMaxPerTaskBack_up = reliPerTask;
%
for i = numTask:-1:1
    indexTask = F.priority_order(i);
    [locationEcu, scheduleBack_up] = tickOutChosenTask(scheduleBack_up, indexTask);
    
    schedule = scheduleBack_up;
    reliPerTask = relMaxPerTaskBack_up;
    [scheduleCellSet, relMaxPerTaskCellSet, frequencyArray] = allocateTaskinECUdvfsFuc(F, indexTask, schedule, ratioRel, reliPerTask, relReq, failureRate, i, d,locationEcu, energySpec);
    [scheduleCellSet, relMaxPerTaskCellSet, frequencyOut] = collectBeamDvfsSchedule(scheduleCellSet, relMaxPerTaskCellSet, beamSearch, energySpec, frequencyArray, indexTask);
    frequencyArrayFinal(indexTask) = frequencyOut;
    
    scheduleBack_up = scheduleCellSet{1};
    relMaxPerTaskBack_up = relMaxPerTaskCellSet{1};
    
end

startTime = 0;
for j = 1:size(fieldnames(scheduleBack_up),1) % 找出优先级最高的任务
    eval(strcat('scheduleHolder = scheduleBack_up.processor',num2str(j),';'));
    for k = 1:size(scheduleHolder,1)
        if scheduleHolder(k,4) == 1
            startTime = scheduleHolder(k,1);
            break
        end
    end
end
if startTime > 0 % 如果优先级最高的任务开始时间不为0，即前面有空隙时，整体前移
    for j = 1:size(fieldnames(scheduleBack_up),1)
        eval(strcat('scheduleHolder = scheduleBack_up.processor',num2str(j),';'));
        for k = 1:size(scheduleHolder,1)
            scheduleHolder(k,1) = scheduleHolder(k,1) - startTime;
            scheduleHolder(k,3) = scheduleHolder(k,3) - startTime;
        end
        eval(strcat('scheduleBack_up.processor',num2str(j),'=scheduleHolder;'));
    end
end

[makeSpan, scheduleOut] = makeSpanCalFuc(scheduleBack_up);