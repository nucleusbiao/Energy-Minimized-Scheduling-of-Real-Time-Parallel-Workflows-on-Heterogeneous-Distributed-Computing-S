function [scheduleCellSet, relMaxPerTaskCellSet, frequencyArray] = allocateTaskinECUdvfsFuc(DAG, ...
                    iTask, schedule, ratioRel, relMaxPerTask, relReq, failureRate, iCountTask, d,locationEcu, energySpec)
frequencyArray = [];
scheduleInput = schedule;
numECU = size(DAG.Wcet,1);
numTask = size(DAG.E, 1);
predArray = pickUpPredFuc(DAG.E, iTask); % pick up predecessor
succArray = pickUpSuccFuc(DAG.E, iTask);
availECU = zeros(1, numECU);
rtECU = zeros(1, numECU) + DAG.relativeDeadline;
DAGWcet = DAG.Wcet;

for i = 1:size(predArray, 2) % ǰ��EST
    preTask = predArray(i);
    ecuOfPreTask = findECUfromScheduleFuc(schedule, preTask);
    EFTofPreTask = findEFTfromScheduleFuc(schedule, preTask);
    for j = 1:numECU
        if eq(ecuOfPreTask, j)
            availECU(j) = max(availECU(j), EFTofPreTask);
        else
            availECU(j) = max(availECU(j), EFTofPreTask+DAG.E(preTask, iTask));
        end
    end
end

for i = 1:size(succArray, 2) %��,RTR
    aftTask = succArray(i);
    ecuOfAftTask = findECUfromScheduleFuc(schedule, aftTask);
    ESTofAftTask = findESTfromScheduleFuc(schedule, aftTask);
    for j = 1:numECU
        if eq(ecuOfAftTask, j)
            rtECU(j) = min(rtECU(j), ESTofAftTask);
        else
            rtECU(j) = min(rtECU(j), ESTofAftTask-DAG.E(iTask, aftTask));
        end
    end
end

finishTimeArray = [];
relReqForiTask = relReq/(ratioRel^(iCountTask - 1)*relArrayMulFuc(relMaxPerTask, iTask));

for i = 1:numECU    
    reliability = exp(-failureRate(i)*DAG.Wcet(i,iTask));    
    wcetLongest = wcetReilCalFuc(relReqForiTask, failureRate(i), DAG.Wcet(i,iTask), d, energySpec, i); % ������ɿ���Ҫ���������ڸô����������ųɵ��Wcet  
    if reliability >= relReqForiTask % �ɿ�������ʱ
        task_wcet = DAG.Wcet(i,iTask);
        timeAvailECU = availECU(i);
        eval(strcat('ecuSchedule = schedule.processor',num2str(i),';'));
        if size(ecuSchedule, 1) == 0 % �ô�����û�а�������ʱ
            if rtECU(i) - availECU(i) >= task_wcet % �ܷ��ڴ˴�����ʱ
                finishTime = rtECU(i);
                finishTimeArray = [finishTimeArray, finishTime];
                frequencyArray(i) = task_wcet/min(rtECU(i) - availECU(i),wcetLongest);
                DAG.Wcet(i,iTask) = min(rtECU(i) - availECU(i),wcetLongest);
            else % �޷����ڴ˴�����ʱ
                finishTimeArray = [finishTimeArray, rtECU(i)]; % [finishTimeArray, 1e20];
                frequencyArray(i) = 1e5;
            end
        elseif size(ecuSchedule, 1) == 1 % �ô�����ֻ������һ������ʱ
            if rtECU(i) - max(availECU(i), ecuSchedule(end,3)) >= task_wcet % �ܷ����Ѱ��ŵ������ʱ
                finishTime = rtECU(i);
                finishTimeArray = [finishTimeArray, finishTime];
                frequencyArray(i) = task_wcet/min(wcetLongest, rtECU(i) - max(availECU(i), ecuSchedule(end,3)));
                DAG.Wcet(i,iTask) = min(wcetLongest, rtECU(i) - max(availECU(i), ecuSchedule(end,3)));    
            elseif min(rtECU(i), ecuSchedule(1,1)) - availECU(i) >= task_wcet % �ܷ����Ѱ��ŵ�����ǰʱ
                finishTime = min(rtECU(i), ecuSchedule(1,1));
                finishTimeArray = [finishTimeArray, finishTime];
                frequencyArray(i) = task_wcet/min(wcetLongest, min(rtECU(i), ecuSchedule(1,1)) - availECU(i));
                DAG.Wcet(i,iTask) = min(wcetLongest, min(rtECU(i), ecuSchedule(1,1)) - availECU(i));
            else % ���ܷ��ڴ˴�����ʱ
                finishTimeArray = [finishTimeArray, rtECU(i)];
                frequencyArray(i) = 1e5;
            end
        end
        
        for j = size(ecuSchedule, 1):-1:2 % �ô�����������>=2������ʱ
            ecuScheduleSort = sortrows(ecuSchedule, 3);
            if rtECU(i) - max(availECU(i), ecuScheduleSort(end,3)) >= task_wcet % �ܷ����Ѱ��ŵ���������֮��ʱ
                finishTime = rtECU(i);
                finishTimeArray = [finishTimeArray, finishTime];
                frequencyArray(i) = task_wcet/min(wcetLongest, rtECU(i) - max(availECU(i), ecuScheduleSort(end,3)));
                DAG.Wcet(i,iTask) = min(wcetLongest, rtECU(i) - max(availECU(i), ecuScheduleSort(end,3)));  
                break
            else
                freeSlack = [ecuScheduleSort(j-1, 3), min(rtECU(i), ecuScheduleSort(j, 1))];
                if freeSlack(2) - max(freeSlack(1),timeAvailECU) >= task_wcet
                    finishTime = freeSlack(2); % max(freeSlack(1),timeAvailECU) + task_wcet;
                    finishTimeArray = [finishTimeArray, finishTime];
                    availECU(i) = max(freeSlack(1),timeAvailECU);
                    frequencyArray(i) = task_wcet/min(wcetLongest, freeSlack(2) - max(freeSlack(1),timeAvailECU));
                    DAG.Wcet(i,iTask) = min(wcetLongest, freeSlack(2) - max(freeSlack(1),timeAvailECU));
                    break
                end
            end
            if j == 2
                if min(ecuScheduleSort(1,1), rtECU(i)) - availECU(i) >= task_wcet % �ܷ����Ѱ��ŵ���������֮ǰʱ
                    finishTime = min(ecuScheduleSort(1,1), rtECU(i));
                    finishTimeArray = [finishTimeArray, finishTime];
                    frequencyArray(i) = task_wcet/min(wcetLongest, min(ecuScheduleSort(1,1), rtECU(i)) - availECU(i));
                    DAG.Wcet(i,iTask) = min(wcetLongest, min(ecuScheduleSort(1,1), rtECU(i)) - availECU(i));
                    break
                else % ���ܷ��ڸô�����ʱ
                    finishTimeArray = [finishTimeArray, rtECU(i)]; % [finishTimeArray, 1e20];
                    frequencyArray(i) = 1e5;
                end
            end
        end
    else % �ɿ��Բ�����ʱ
        finishTimeArray = [finishTimeArray, rtECU(i)]; % [finishTimeArray, 1e20];
        frequencyArray(i) = 1e10;
    end

    if frequencyArray(i) < 0
        frequencyArray(i) = 1e20;
        DAG.Wcet(i,iTask) = DAGWcet(i,iTask); % ԭ������=1
    end
end

failArray = [1e5,1e10,1e20];
DVFSfaluseFlag = setdiff(frequencyArray,failArray);
if isempty(DVFSfaluseFlag) % ����������޷����Ⱦ�ά��ԭ״
    frequencyArray(locationEcu) = 1;
    DAG.Wcet(locationEcu,iTask) = DAGWcet(locationEcu,iTask);
end

for indexECU = 1:numECU
    if frequencyArray(indexECU) <=1
        finishTimeEarliest = finishTimeArray(indexECU);
        slot = [finishTimeEarliest - DAG.Wcet(indexECU,iTask), finishTimeEarliest];
        eval(strcat('ecuSchedule = schedule.processor',num2str(indexECU),';'));
        ecuSchedule = insertSlot(ecuSchedule, slot, iTask,iCountTask);
        eval(strcat('schedule.processor',num2str(indexECU),' = ecuSchedule;'));
%         relMaxPerTask(iTask) = exp(-failureRate(indexECU)*DAG.Wcet(indexECU,iTask));
        relMaxPerTask(iTask) = exp(-failureRate(indexECU) * 10^(d*(energySpec(indexECU,6)-frequencyArray(indexECU))/(energySpec(indexECU,6)-energySpec(indexECU,5))) * DAG.Wcet(indexECU,iTask)); %����ÿ���������Ƶ�ʺ�Ŀɿ���!!!!!!!!!!!!!!
        relMaxPerTaskCellSet{indexECU} = relMaxPerTask;
        scheduleCellSet{indexECU} = schedule;
        schedule = scheduleInput;
    else
        relMaxPerTaskCellSet{indexECU} = [];
        scheduleCellSet{indexECU} = [];
    end
end