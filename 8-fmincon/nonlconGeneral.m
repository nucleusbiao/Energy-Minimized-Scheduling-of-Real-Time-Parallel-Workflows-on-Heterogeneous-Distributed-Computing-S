function [c,ceq] = nonlconGeneral(x, DAG, choicePro, failureRate, set, d)
taskNum = size(DAG.Wcet, 2) - 1;
proNum = size(DAG.Wcet, 1);
y = zeros(1, taskNum*proNum);
wij = DAG.Wcet(:,1:taskNum);
e = DAG.E;
for i = 1:size(choicePro, 2) %公式10
    y(i+(choicePro(i)-1)*taskNum) = 1;
end
fmax = set(:,5)';
fmin = set(:,4)';
c = [];
for i = 1:taskNum %公式11-优先级：执行顺序
    for j = 1:taskNum
        if e(i,j) ~= -1
            c = [c; x(taskNum+i) - x(taskNum+j)];
            for k = 0:proNum-1
                c(end) = c(end) + y(i+k*taskNum)*wij(k+1,i)/x(i) + 1/2*abs(y(i+k*taskNum)-y(j+k*taskNum))*e(i,j);
            end
        end
    end
end

for i = 1:taskNum %公式12-任两个任务的执行时间不能在同一个处理器上重叠
    for j = i+1:taskNum
        temp1 = 0;
        temp2 = (x(taskNum+i) - x(taskNum+j));
        temp3 = (x(taskNum+j) - x(taskNum+i));
        for k = 1:proNum
            temp1 = temp1 + (y(i+(k-1)*taskNum)*y(j+(k-1)*taskNum));
            temp2 = temp2 + (y(i+(k-1)*taskNum)*wij(k,i)/x(i));
            temp3 = temp3 + (y(j+(k-1)*taskNum)*wij(k,j)/x(j));
        end
         c = [c; temp1*temp2*temp3];
    end
end

exitTask = find(all(DAG.E == -1, 2) == 1);
for i = 1:size(exitTask, 1) %公式13-满足截止时间约束-最后的出口任务执行时间小于实时性约束
    c = [c; x(taskNum+exitTask(i)) - DAG.relativeDeadline];
    for k = 1:proNum
        c(end) = c(end) + y(exitTask(i)+(k-1)*taskNum)*wij(k,exitTask(i))/x(exitTask(i));
    end
end

c = [c; DAG.relReq];
temp4 = 1;
for i = 1:taskNum %公式14-满足可靠性约束
    temp5 = 0;
    for k = 1:proNum
        temp5 = temp5 + y(i+(k-1)*taskNum)*exp(1)^(-failureRate(k)*10^(d*(fmax(k)-x(i))/(fmax(k)-fmin(k)))*(wij(k,i)*fmax(k)/x(i)));
    end
    temp4 = temp4 * temp5;
end 
c(end) = c(end) - temp4;
ceq = [];