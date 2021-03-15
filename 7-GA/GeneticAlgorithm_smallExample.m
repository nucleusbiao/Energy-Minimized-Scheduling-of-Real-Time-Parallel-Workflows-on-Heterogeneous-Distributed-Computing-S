clear
clc
close all

proNum = 4; % 处理器数量
taskNum = 6; % 任务数
d = 3; %代表失败率对电压缩放的敏感程度

DAG = FunctionClass;
DAG.arrivalTime = 0;
failureRate = [9e-5 6e-5 6e-5 5e-5]; %每个处理器的失败率
DAG.E = [-1 20 24 -1 -1 -1; %每个
    -1 -1 -1 12 -1 -1;
    -1 -1 -1 -1 43 -1;
    -1 -1 -1 -1 -1 70;
    -1 -1 -1 -1 -1 93;
    -1 -1 -1 -1 -1 -1];
DAG.Wcet = [37,23,76,61,72,67,1; %每个任务在每个处理器上的执行时间，最后一列为处理器编号
    54,49,28,26,96,54,2;
    96,39,45,25,70,81,3;
    96,59,24,21,10,54,4];
set = [ 0.06 1.1 2.8 0.1 1; %
    0.05 1   3   0.1 1;
    0.05 1.1 2.5 0.1 1;
    0.05 0.8 3   0.1 1];

relReq = 0.91; % 设置总的可靠性要求
DAG.relativeDeadline = 331.5; % 设置截至时间

rankUvalueInitial = zeros(1, taskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % 算出每个任务的rank值并排序

info.ng=12000; % GA的迭代次数
info.np=40; % 遗传算法的种群规模
info.pc=0.5; % 交叉概率
info.pm=0.5; % 变异概率 0.5
info.m = proNum; % 处理器数量
info.n = taskNum; % 任务数
info.cmax = DAG.relativeDeadline; % 截止时间要求
datact = DAG.Wcet; % 执行时间
data.st = DAG.E; % 反应时间
data = setupDataForRandomLoop( data, datact );
data.p = zeros(1,info.m); % 属于动态能量，可以通过让系统休眠来去除。Pk,ind
data.c = set(:,2)';  % 系数C，动态能量中的β
data.mk = set(:,3)'; % 动态能量中的指数mj
data.f = set(:,4)'; % 各个CPU的最小频率
data.pks = set(:,1)'; % 静态能量系数，可以通过关闭整个系统来去除

[AFTForTasks,ScheduleResult] = MSLFuc( DAG, relReq, failureRate);
pop=rand(info.np, info.n*3); % 40*30，40行为40个个体，每个个体都有多个任务。列均分为三部分，用来分配CPU、排优先级、设置任务频率(现在设置为0.8~1.0之间的随机数)
cpuArray = zeros(1,taskNum);
for m = 1:proNum
    eval(strcat('processorArray = ScheduleResult.processor',num2str(m),';'));
    if ~isempty(processorArray)
        for k = 1:size(processorArray,1)
            cpuArray(processorArray(k,end)) = m;
        end
    end
end
cpuArray1 = (cpuArray-0.5)/proNum;
pop(1, 1:info.n) = cpuArray1;
pop(1, info.n*2+1:info.n*3) = 1;
cpuArray2 = repmat(cpuArray1, [info.np,1]);
pop(1:info.np, 1:info.n) = cpuArray2;
popfmin = 10000;
popf = randi([popfmin,10000], info.np, info.n)/10000;
pop(1:info.np, info.n*2+1:info.n*3) = popf;
[SaveArray, SLtime] = forLoopFuc(info, data, relReq, failureRate, pop, popfmin);

fprintf('schedule length is %f\n', SaveArray(2));
fprintf('energy consumption is %f\n', SaveArray(1));