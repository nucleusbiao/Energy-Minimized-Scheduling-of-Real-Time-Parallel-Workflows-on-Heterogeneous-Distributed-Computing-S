function [dataNeed] = resInformation(res_fmincon, DAG, failureRate, set, d)
% �ѵ��Ƚ����Ϣ��������
taskNum = size(DAG.E, 1);
for i = 1:taskNum
    doneTime(i) = res_fmincon(i+1+taskNum*2) + DAG.Wcet(res_fmincon(i+1), i)/res_fmincon(i+1+taskNum);
end
sl = max(doneTime); %����ʱ��

wij = DAG.Wcet(:,1:taskNum);
fmax = set(:,5)';
fmin = set(:,4)';
relTotal = 1; %�ܵĿɿ���
for i = 1:taskNum %��ʽ14-����ɿ���Լ��
    pro = res_fmincon(i+1); %�������ڵĴ�����
    fi = res_fmincon(i+1+taskNum); %�����Ƶ��
    relPerTask(i) = exp(1)^(-failureRate(pro)*10^(d*(fmax(pro)-fi)/(fmax(pro)-fmin(pro)))*(wij(pro,i)*fmax(pro)/fi));
    relTotal = relTotal * relPerTask(i);
end

dataNeed = [sl, DAG.relativeDeadline, relTotal, DAG.relReq, res_fmincon(2:end)]; % ����ʱ��������ʱ��Լ�����ɿ��ԡ��ɿ���Լ�����������ڴ��������顢����Ƶ�����顢����ʼִ�е�ʱ������
end