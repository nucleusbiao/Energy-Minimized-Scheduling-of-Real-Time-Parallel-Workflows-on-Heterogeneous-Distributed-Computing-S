clear
clc
close all

proNum = 4; % 处理器数量
taskNum = 6; % 任务数
d = 3;   %代表失败率对电压缩放的敏感程度

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
energySpec = [0.1 0.06 1.1 2.8 0.1 1; %
    0.1 0.05 1   3   0.1 1;
    0.1 0.05 1.1 2.5 0.1 1;
    0.1 0.05 0.8 3   0.1 1];

relReq = 0.91; % 设置总的可靠性要求
DAG.relativeDeadline = 331.5; % 设置截至时间
[SaveArray, SLtime] = forLoopFuc(DAG, relReq, energySpec, failureRate, d);
fprintf('schedule length is %f\n', SaveArray(1));
fprintf('energy consumption is %f\n', SaveArray(2));