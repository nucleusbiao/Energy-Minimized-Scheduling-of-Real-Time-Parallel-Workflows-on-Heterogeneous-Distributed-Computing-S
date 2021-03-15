function [dataNeed] = resInformation(res_fmincon, DAG, failureRate, set, d)
% 把调度结果信息保存起来
taskNum = size(DAG.E, 1);
for i = 1:taskNum
    doneTime(i) = res_fmincon(i+1+taskNum*2) + DAG.Wcet(res_fmincon(i+1), i)/res_fmincon(i+1+taskNum);
end
sl = max(doneTime); %调度时长

wij = DAG.Wcet(:,1:taskNum);
fmax = set(:,5)';
fmin = set(:,4)';
relTotal = 1; %总的可靠性
for i = 1:taskNum %公式14-满足可靠性约束
    pro = res_fmincon(i+1); %任务所在的处理器
    fi = res_fmincon(i+1+taskNum); %任务的频率
    relPerTask(i) = exp(1)^(-failureRate(pro)*10^(d*(fmax(pro)-fi)/(fmax(pro)-fmin(pro)))*(wij(pro,i)*fmax(pro)/fi));
    relTotal = relTotal * relPerTask(i);
end

dataNeed = [sl, DAG.relativeDeadline, relTotal, DAG.relReq, res_fmincon(2:end)]; % 调度时长、调度时长约束、可靠性、可靠性约束、任务所在处理器数组、任务频率数组、任务开始执行的时间数组
end