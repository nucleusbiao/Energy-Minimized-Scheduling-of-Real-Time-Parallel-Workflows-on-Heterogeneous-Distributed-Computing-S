function [c,ceq] = nonlcon1111(x, DAG, choicePro, failureRate, set)
taskNum = size(DAG.Wcet, 2) - 1;
proNum = size(DAG.Wcet, 1);
y = zeros(1, taskNum*proNum);
wij = DAG.Wcet(:,1:taskNum);
e = DAG.E;
for i = 1:size(choicePro, 2) %公式10
    y(i+(choicePro(i)-1)*taskNum) = 1;
end
d = 3;
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
    
% c =  [ %写成小于等于0的形式
%     (x(5)+ (y(1)*14/x(1)+1/2*abs(y(1)-y(2))*18 +y(5)*16/x(1)+1/2*abs(y(5)-y(6))*18 +y(9)*9/x(1)+1/2*abs(y(9)-y(10))*18) ) - x(6); %公式11-优先级：执行顺序
%     (x(6)+ (y(2)*13/x(2)+1/2*abs(y(2)-y(3))*12 +y(6)*19/x(2)+1/2*abs(y(6)-y(7))*12 +y(10)*18/x(2)+1/2*abs(y(10)-y(11))*12) ) - x(7);
%     (x(7)+ (y(3)*11/x(3)+1/2*abs(y(3)-y(4))*9 +y(7)*13/x(3)+1/2*abs(y(7)-y(8))*9 +y(11)*19/x(3)+1/2*abs(y(11)-y(12))*9) ) - x(8);
%     
%     (y(1)*y(2)+y(5)*y(6)+y(9)*y(10)) * (x(5)+ (y(1)*14/x(1)+y(5)*16/x(1)+y(9)*9/x(1)) -x(6)) * (x(6)+ (y(2)*13/x(2)+y(6)*19/x(2)+y(10)*18/x(2)) -x(5)); %公式12-任两个任务的执行时间不能在同一个处理器上重叠
%     (y(1)*y(3)+y(5)*y(7)+y(9)*y(11)) * (x(5)+ (y(1)*14/x(1)+y(5)*16/x(1)+y(9)*9/x(1)) -x(7)) * (x(7)+ (y(3)*11/x(3)+y(7)*13/x(3)+y(11)*19/x(3)) -x(5));
%     (y(1)*y(4)+y(5)*y(8)+y(9)*y(12)) * (x(5)+ (y(1)*14/x(1)+y(5)*16/x(1)+y(9)*9/x(1)) -x(8)) * (x(8)+ (y(4)*13/x(4)+y(8)*8/x(4)+y(12)*17/x(4)) -x(5));
%     (y(2)*y(3)+y(6)*y(7)+y(10)*y(11)) * (x(6)+ (y(2)*13/x(2)+y(6)*19/x(2)+y(10)*18/x(2)) -x(7)) * (x(7)+ (y(3)*11/x(3)+y(7)*13/x(3)+y(11)*19/x(3)) -x(6));
%     (y(2)*y(4)+y(6)*y(8)+y(10)*y(12)) * (x(6)+ (y(2)*13/x(2)+y(6)*19/x(2)+y(10)*18/x(2)) -x(8)) * (x(8)+ (y(4)*13/x(4)+y(8)*8/x(4)+y(12)*17/x(4)) -x(6));
%     (y(3)*y(4)+y(7)*y(8)+y(11)*y(12)) * (x(7)+ (y(3)*11/x(3)+y(7)*13/x(3)+y(11)*19/x(3)) -x(8)) * (x(8)+ (y(4)*13/x(4)+y(8)*8/x(4)+y(12)*17/x(4)) -x(7));
%     
%     x(8)+(y(4)*13/x(4)+ y(8)*8/x(4)+ y(12)*17/x(4)) - DAG.relativeDeadline; %公式13-满足截止时间约束-最后的出口任务执行时间小于实时性约束
%     
%     DAG.relReq - (y(1)*exp(1)^(-failureRate(1)* 10^(d*(fmax(1)-x(1))/(fmax(1)-fmin(1)))* (wij(1,1)*fmax(1))/x(1)) +y(5)*exp(1)^(-failureRate(2)*10^(d*(fmax(2)-x(1))/(fmax(2)-fmin(2)))*(wij(2,1)*fmax(2))/x(1)) +y(9)*exp(1)^(-failureRate(3)*10^(d*(fmax(3)-x(1))/(fmax(3)-fmin(3)))*(wij(3,1)*fmax(3))/x(1)))* ...
%     (y(2)*exp(1)^(-failureRate(1)*10^(d*(fmax(1)-x(2))/(fmax(1)-fmin(1)))*(wij(1,2)*fmax(1))/x(2)) +y(6)*exp(1)^(-failureRate(2)*10^(d*(fmax(2)-x(2))/(fmax(2)-fmin(2)))*(wij(2,2)*fmax(2))/x(2)) +y(10)*exp(1)^(-failureRate(3)*10^(d*(fmax(3)-x(2))/(fmax(3)-fmin(3)))*(wij(3,2)*fmax(3))/x(2)))* ...
%     (y(3)*exp(1)^(-failureRate(1)*10^(d*(fmax(1)-x(3))/(fmax(1)-fmin(1)))*(wij(1,3)*fmax(1))/x(3)) +y(7)*exp(1)^(-failureRate(2)*10^(d*(fmax(2)-x(3))/(fmax(2)-fmin(2)))*(wij(2,3)*fmax(2))/x(3)) +y(11)*exp(1)^(-failureRate(3)*10^(d*(fmax(3)-x(3))/(fmax(3)-fmin(3)))*(wij(3,3)*fmax(3))/x(3)))* ...
%     (y(4)*exp(1)^(-failureRate(1)*10^(d*(fmax(1)-x(4))/(fmax(1)-fmin(1)))*(wij(1,4)*fmax(1))/x(4)) +y(8)*exp(1)^(-failureRate(2)*10^(d*(fmax(2)-x(4))/(fmax(2)-fmin(2)))*(wij(2,4)*fmax(2))/x(4)) +y(12)*exp(1)^(-failureRate(3)*10^(d*(fmax(3)-x(4))/(fmax(3)-fmin(3)))*(wij(3,4)*fmax(3))/x(4)))%公式14-满足可靠性约束
%     ];
ceq = [];