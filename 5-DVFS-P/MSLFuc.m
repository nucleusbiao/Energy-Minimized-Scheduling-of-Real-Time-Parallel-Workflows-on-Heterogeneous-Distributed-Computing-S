 function [AFTForTasks,ScheduleResult] = MSLFuc( DAG, relReq, failureRate)
%%
numProcessor = size(DAG.Wcet, 1); %下面几行到空行之前是初始化
numTask = size(DAG.Wcet, 2)-1;
relPerTask=[];
AFTForTasksA = [];
stopFlagMSL = 0;
for i=1:numProcessor          
    eval(strcat('schedule.processor',num2str(i),' = [];'));
end

[relMax, relMaxPerTask] = relMaxFuc(DAG, failureRate);  % 求出非DVFS最大可靠性和每个任务的最大可靠性
if relMax < relReq
    AFTForTasks = 0; % 变成一个标志位
    % fprintf(1,'MSLFuc中15行左右无法找到满足可靠性的处理器\n\n');
else
    for i = 1:numTask
        ScheduleLengthArray = [];
        indexTask = DAG.priority_order(i); % 按照优先级依次选出要执行的任务
        relDenominator = 1; 
        
        % 下面7行通过公式21算出该任务的所需可靠性(MSL算法第8行)
        for j = 1:i-1
            relDenominator = relDenominator * relPerTask(j);
        end
        for j = i+1:numTask
            relDenominator = relDenominator * relMaxPerTask(j);
        end
        relReqForiTask = relReq/relDenominator;
        
        % 下面是将每个任务轮流放入每个p，并把满足可靠性的全保存起来，选择这之中AFT最小的那个
        % WcetPerTaski = []; % 存放执行时间，来选最小执行时间的
        indexPro = []; % 存放对应的处理器的序号
        relPerTaski = []; % 存放对应的任务在所有处理器中的可靠性
        FalseNumber = 0;
        predArray = pickUpPredFuc(DAG.E, indexTask); % 标记第几个任务到第i个任务有反应时间的位置
        for j = 1:numProcessor
            reliability = exp(-failureRate(j)*DAG.Wcet(j,indexTask)); % 算出第i个任务在处理器j上的可靠性（根据公式4）
            
            if reliability < relReqForiTask
                FalseNumber = FalseNumber + 1;
                relPerTaski = [relPerTaski,reliability];
                indexPro = [indexPro,j];
                ScheduleLengthArray = [ScheduleLengthArray, inf];
                if FalseNumber == numProcessor
                    AFTForTasks = 0; % 变成一个标志位
                    stopFlagMSL = 1;
                    continue
                    % fprintf(1,'MSLFuc中41行左右无法找到满足可靠性的处理器\n\n');
                end
            else
                % 这里本来要把t放入p的，但我放在下面的if中与AFT一起赋值
                relPerTaski = [relPerTaski,reliability];
                indexPro = [indexPro,j];
                % WcetPerTaski = [WcetPerTaski,DAG.Wcet(j,indexTask)];
                ESTForiTask = ESTForiTaskFuc( j, indexTask, predArray, schedule, DAG );
                ScheduleLengthArray = [ScheduleLengthArray, DAG.Wcet(j,indexTask) + ESTForiTask];
                
            end
            if j == numProcessor
                [a,b] = sort(ScheduleLengthArray);
                choicedPro = indexPro(b(1));
                relPerTask=[relPerTask,relPerTaski(b(1))]; % 将实际每个任务的可靠性存起来
            end
        end
        
        if stopFlagMSL == 1
            break
        end
        
        % 下面是用公式22计算AFT；并把算的存起来
        % predArray = pickUpPredFuc(DAG.E, indexTask); % 标记第几个任务到第i个任务有反应时间的位置
        ESTForiTask = ESTForiTaskFuc( choicedPro, indexTask, predArray, schedule, DAG );
        AFTForiTask=ESTForiTask + DAG.Wcet(choicedPro,indexTask);
        eval(strcat('schedule.processor',num2str(choicedPro),'=[schedule.processor',num2str(choicedPro),';ESTForiTask,DAG.Wcet(choicedPro,indexTask),AFTForiTask,i,indexTask];'));
        % 将任务放进处理器里
        % schedule.processorj中存储的是 任务开始时间，消耗时间，完成时间，第几个执行的任务，被执行任务的编号

        AFTForTasksA = [AFTForTasksA,AFTForiTask]; % 用来求出调度时长
        if i == numTask
            AFTForTasksA = sort(AFTForTasksA, 'descend');
            AFTForTasks = AFTForTasksA(1);
        end
    end
end
ScheduleResult = schedule;