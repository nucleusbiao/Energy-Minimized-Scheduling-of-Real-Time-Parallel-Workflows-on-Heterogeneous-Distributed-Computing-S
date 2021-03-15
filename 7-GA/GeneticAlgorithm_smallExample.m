clear
clc
close all

proNum = 4; % ����������
taskNum = 6; % ������
d = 3; %����ʧ���ʶԵ�ѹ���ŵ����г̶�

DAG = FunctionClass;
DAG.arrivalTime = 0;
failureRate = [9e-5 6e-5 6e-5 5e-5]; %ÿ����������ʧ����
DAG.E = [-1 20 24 -1 -1 -1; %ÿ��
    -1 -1 -1 12 -1 -1;
    -1 -1 -1 -1 43 -1;
    -1 -1 -1 -1 -1 70;
    -1 -1 -1 -1 -1 93;
    -1 -1 -1 -1 -1 -1];
DAG.Wcet = [37,23,76,61,72,67,1; %ÿ��������ÿ���������ϵ�ִ��ʱ�䣬���һ��Ϊ���������
    54,49,28,26,96,54,2;
    96,39,45,25,70,81,3;
    96,59,24,21,10,54,4];
set = [ 0.06 1.1 2.8 0.1 1; %
    0.05 1   3   0.1 1;
    0.05 1.1 2.5 0.1 1;
    0.05 0.8 3   0.1 1];

relReq = 0.91; % �����ܵĿɿ���Ҫ��
DAG.relativeDeadline = 331.5; % ���ý���ʱ��

rankUvalueInitial = zeros(1, taskNum);
DAG = upwardRankFuc(DAG, rankUvalueInitial);  % ���ÿ�������rankֵ������

info.ng=12000; % GA�ĵ�������
info.np=40; % �Ŵ��㷨����Ⱥ��ģ
info.pc=0.5; % �������
info.pm=0.5; % ������� 0.5
info.m = proNum; % ����������
info.n = taskNum; % ������
info.cmax = DAG.relativeDeadline; % ��ֹʱ��Ҫ��
datact = DAG.Wcet; % ִ��ʱ��
data.st = DAG.E; % ��Ӧʱ��
data = setupDataForRandomLoop( data, datact );
data.p = zeros(1,info.m); % ���ڶ�̬����������ͨ����ϵͳ������ȥ����Pk,ind
data.c = set(:,2)';  % ϵ��C����̬�����еĦ�
data.mk = set(:,3)'; % ��̬�����е�ָ��mj
data.f = set(:,4)'; % ����CPU����СƵ��
data.pks = set(:,1)'; % ��̬����ϵ��������ͨ���ر�����ϵͳ��ȥ��

[AFTForTasks,ScheduleResult] = MSLFuc( DAG, relReq, failureRate);
pop=rand(info.np, info.n*3); % 40*30��40��Ϊ40�����壬ÿ�����嶼�ж�������о���Ϊ�����֣���������CPU�������ȼ�����������Ƶ��(��������Ϊ0.8~1.0֮��������)
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