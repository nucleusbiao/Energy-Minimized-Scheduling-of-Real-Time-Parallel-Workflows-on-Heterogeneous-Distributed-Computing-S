function ESTForiTask = ESTForiTaskFuc( processor, taskIndex, predArray, schedule, DAG )
% 用于计算任务的最早开始时间
m=0; % 用于标记之前有几个任务与该任务有联系
scheduleBF=[];
eval(strcat('scheduleBF = schedule.processor',num2str(processor),';'));
mm = isempty(scheduleBF);
availPro = DAG.arrivalTime;
if mm == 0
    availPro = scheduleBF(end,3); % 求出该处理器的可用时间
end
AFTForPredTask = 0;
for i=1:size(predArray,2) % 看有几个之前相关的任务
    if predArray(i)>0
        m=m+1;
    end
end
InsertFlag = 0;

if m==0 % 没有前任任务时，即第一个任务时
    if DAG.priority_order(1) == taskIndex
        ESTForiTask = DAG.arrivalTime; % 为第一个执行的任务时
    else % 虽然没有前任任务，但此处理器之前分配过任务时，尝试嵌入任务！！
        if size(scheduleBF, 1) == 0
            ESTForiTask = DAG.arrivalTime;
        else
            ESTForiTask = max(scheduleBF(:,3));
        end
        if size(scheduleBF, 1) >= 1
            FinishArray = [];
            BiginArray = [];
            for l=1:size(scheduleBF,1) % 把该处理器中所有任务的开始时间和结束时间存起来
                FinishArray = [FinishArray, scheduleBF(l,3)];
                BiginArray = [BiginArray, scheduleBF(l,1)];
            end
            FinishArray = sort(FinishArray);
            BiginArray = sort(BiginArray);
            for q = 1:size(scheduleBF, 1) % 尝试嵌入任务
                if q == 1 % 尝试嵌入这个处理器第一个任务之前时
                    if (BiginArray(q)-DAG.arrivalTime) > DAG.Wcet(processor,taskIndex)
                        ESTForiTask = DAG.arrivalTime;
                        break
                    end
                elseif (BiginArray(q)-FinishArray(q-1)) > DAG.Wcet(processor,taskIndex) % 尝试嵌入这个处理器的非第一个任务之前时
                    ESTForiTask = FinishArray(q-1);
                    break
                end
            end
        end
    end 
else % 有前任任务时
    PredNumflag = 0;
    ESTForiTaskArray = [];
    for i=1:size(DAG.Wcet,1)
        eval(strcat('n = schedule.processor',num2str(i),';'));
        if isempty(n)
            continue
        else
            ProArray = [];
            for j = 1:size(n,1) % 把处理器中的任务序号存起来
                ProArray = [ProArray, n(j,5)];
            end
            intersectionArray = intersect(predArray, ProArray); % 找出该处理器内前任任务
            if isempty(intersectionArray) % 该处理器内无前任任务时
                continue
            else % 该处理器内有前任任务时
                for k = 1:size(intersectionArray,2)
                    for g = 1:size(n,1) % 选中前任任务的行
                        if n(g, 5) == intersectionArray(k)
                            break
                        end
                    end
                    if i == processor
                        ESTForiTaskArray = [ESTForiTaskArray, n(g, 3)];
                        PredNumflag = PredNumflag+1;
                        % intersectionArray(k) = []; % 把已找到的前任任务去掉，还没写完
                    else
                        ESTForiTaskArray = [ESTForiTaskArray, n(g, 3) + DAG.E(intersectionArray(k),taskIndex)];
                        PredNumflag = PredNumflag+1;
                        % intersectionArray(k) = []; % 把已找到的前任任务去掉，还没写完
                    end
                end
                if PredNumflag == m % 前任任务已经找全的情况
                    ESTDescendArray = sort(ESTForiTaskArray, 'descend');
                    FinishArray = [];
                    BiginArray = [];
                    for l=1:size(scheduleBF,1) % 把该处理器中所有任务的开始时间和结束时间存起来，用来尝试嵌入
                        FinishArray = [FinishArray, scheduleBF(l,3)];
                        BiginArray = [BiginArray, scheduleBF(l,1)];
                    end
                    FinishArray = sort(FinishArray);
                    BiginArray = sort(BiginArray);
                    if isempty(scheduleBF)
                        ESTForiTask = ESTDescendArray(1);
                        break
                    else
                        for q = 1:size(scheduleBF,1) % 尝试嵌入任务
                            if q == 1 % 尝试嵌入这个处理器第一个任务之前时
                                if (BiginArray(q)-ESTDescendArray(1)) > DAG.Wcet(processor,taskIndex)
                                    ESTForiTask = ESTDescendArray(1);
                                    InsertFlag = 1;
                                    break
                                end
                            elseif ((BiginArray(q)-FinishArray(q-1))>DAG.Wcet(processor,taskIndex)) && ((BiginArray(q)-ESTDescendArray(1))>DAG.Wcet(processor,taskIndex)) % 尝试嵌入这个处理器的非第一个任务之前时
                                if FinishArray(q-1) > ESTDescendArray(1)
                                    ESTForiTask = FinishArray(q-1);
                                    InsertFlag = 1;
                                    break
                                else
                                    ESTForiTask = ESTDescendArray(1);
                                    InsertFlag = 1;
                                    break
                                end 
                            end
                        end
                        if InsertFlag == 0 % 嵌入失败的情况
                            ESTForiTask = max(ESTDescendArray(1), FinishArray(end));
                        end
                        break
                    end
                end
                
            end
        end
    end
end
% elseif m==1 % 前面相关任务只有一个时
%     predPro = 0;
%     for i=1:size(DAG.Wcet,1) % 找出之前相关任务所在的处理器，并取出前任务的完成时间
%         
%         eval(strcat('n = schedule.processor',num2str(i),';'));
%         if isempty(n)
%             continue
%         else
%             eval(strcat('n = schedule.processor',num2str(i),'(:,5);'));
%             for j=1:size(n,1)
%                 if n(j) == predArray
%                     eval(strcat('AFTForPredTask = schedule.processor',num2str(i),'(j,3);')); % 前任务的完成时间
%                     eval(strcat('predPro=i;')); % 前任务所在处理器
%                 end
%             end
%         end
%     end
%     if predPro ~= 0
%         if processor == predPro % 与前任务在同一处理器时
%             ESTForiTask = max(availPro,AFTForPredTask);
%         else % 与前任务在不同处理器时
%             ESTForiTask = max(availPro,AFTForPredTask + DAG.E(predArray,task));
%         end
%     end
% else % 前面相关任务有两个时
%     predPro1 = 0;
%     predPro2 = 0;
%     for i=1:size(DAG.Wcet,1) % 找出之前相关任务所在的处理器，并取出前任务的完成时间
%         eval(strcat('n = schedule.processor',num2str(i),';'));
%         if isempty(n)
%             continue
%         else
%             eval(strcat('n = schedule.processor',num2str(i),'(:,5);'));
%             for j=1:size(n,1)
%                 if n(j) == predArray(1)
%                     eval(strcat('AFTForPredTask1 = schedule.processor',num2str(i),'(j,3);')); % 前任务的完成时间
%                     eval(strcat('predPro1=i;')); % 前任务所在处理器
%                 end
%                 if n(j) == predArray(2)
%                     eval(strcat('AFTForPredTask2 = schedule.processor',num2str(i),'(j,3);')); % 前任务的完成时间
%                     eval(strcat('predPro2=i;')); % 前任务所在处理器
%                 end
%             end
%         end
%     end
%     
%  %   if predPro1 ~= 0
%         if predPro1 == predPro2 % 当两个前任务在同一处理器时
%             if processor == predPro1 % 与前任务在同一处理器时
%                 ESTForiTask = max(AFTForPredTask1,AFTForPredTask2);
%                 ESTForiTask = max(availPro,ESTForiTask);
%             else % 与前任务在不同处理器时
%                 if AFTForPredTask1 > AFTForPredTask2
%                     ESTForiTask = max(availPro,AFTForPredTask1 + DAG.E(predArray(1),task));
%                 else
%                     ESTForiTask = max(availPro,AFTForPredTask2 + DAG.E(predArray(2),task));
%                 end
%             end
%             
%         else % 当两个前任务不在同一处理器时
%             if processor == predPro1 % 与某个前任务在同一处理器时
%                 if (AFTForPredTask2 + DAG.E(predArray(2),task)) > AFTForPredTask1
%                     ESTForiTask = max(availPro,AFTForPredTask2 + DAG.E(predArray(2),task));
%                 else
%                     ESTForiTask = max(availPro,AFTForPredTask1);
%                 end
%             elseif processor == predPro2
%                 if (AFTForPredTask1 + DAG.E(predArray(1),task)) > AFTForPredTask2
%                     ESTForiTask = max(availPro,AFTForPredTask1 + DAG.E(predArray(1),task));
%                 else
%                     ESTForiTask = max(availPro,AFTForPredTask2);
%                 end
%             else % 与前任务都不在同一处理器时
%                 ESTForiTask = max((AFTForPredTask1 + DAG.E(predArray(1),task)), (AFTForPredTask2 + DAG.E(predArray(2),task)));
%                 ESTForiTask = max(availPro,ESTForiTask);
%             end
%         end
%  %   end
% end