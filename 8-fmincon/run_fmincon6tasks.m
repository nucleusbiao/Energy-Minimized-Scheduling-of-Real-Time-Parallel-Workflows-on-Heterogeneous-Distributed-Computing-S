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

DAG.relReq = 0.91; % �����ܵĿɿ���Ҫ��
DAG.relativeDeadline = 331.5; % ���ý���ʱ��
    
tic
res_fmincon = [];
for i = 1:proNum
    for j = 1:proNum
        for k = 1:proNum
            for m = 1:proNum
                for n = 1:proNum
                    for v = 1:proNum
                        choiceProArr = [i, j, k, m, n, v];
                        [x,fval,exitflag,output,lambda,grad,hessian] = fminconFunc1221(choiceProArr, DAG, failureRate, set, d);
                        res_fmincon(end+1, :) = [fval, choiceProArr, x']; %�ܺ�1��������ѡ��4��Ƶ��4����ʼʱ��Լ��4
                    end
                end
            end
        end
    end
end
toc
SLtime = toc;
res_fmincon_order = sortrows(res_fmincon, 1);
dataNeed = resInformation(res_fmincon_order(1,:), DAG, failureRate, set, d); % ����ʱ��������ʱ��Լ�����ɿ��ԡ��ɿ���Լ�����������ڴ��������顢����Ƶ�����顢����ʼִ�е�ʱ������

fprintf('schedule length is %f\n', dataNeed(1));
fprintf('energy consumption is %f\n', res_fmincon_order(1,1));