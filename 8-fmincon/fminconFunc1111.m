function [xArr,fval,exitflag,output,lambda,grad,hessian] = fminconFunc1111(choicePro, DAG, failureRate, set)
taskNum = size(DAG.Wcet, 2) - 1;
proNum = size(DAG.Wcet, 1);
y = zeros(1, taskNum*proNum);
for i = 1:size(choicePro, 2) %公式10
    y(i+(choicePro(i)-1)*taskNum) = 1;
end
wij = DAG.Wcet(:,1:taskNum);

% funTemp = 0;
% for i = 1:taskNum
%     for k = 1:proNum
%         funTemp = funTemp + y(i+(k-1)*taskNum)*(set(k,1)+set(k,2)*x(i)^set(k,3))*set(k,5)/x(i)*wij(k,i);
%     end
% end
% fun = @(x) funTemp;
fun = @(x) y(1)*(set(1,1)+set(1,2)*x(1)^set(1,3))*set(1,5)/x(1)*wij(1,1) + y(2)*(set(1,1)+set(1,2)*x(2)^set(1,3))*set(1,5)/x(2)*wij(1,2) + y(3)*(set(1,1)+set(1,2)*x(3)^set(1,3))*set(1,5)/x(3)*wij(1,3) + y(4)*(set(1,1)+set(1,2)*x(4)^set(1,3))*set(1,5)/x(4)*wij(1,4) ...
    + y(5)*(set(2,1)+set(2,2)*x(1)^set(2,3))*set(2,5)/x(1)*wij(2,1) + y(6)*(set(2,1)+set(2,2)*x(2)^set(2,3))*set(2,5)/x(2)*wij(2,2) + y(7)*(set(2,1)+set(2,2)*x(3)^set(2,3))*set(2,5)/x(3)*wij(2,3) + y(8)*(set(2,1)+set(2,2)*x(4)^set(2,3))*set(2,5)/x(4)*wij(2,4) ...
    + y(9)*(set(3,1)+set(3,2)*x(1)^set(3,3))*set(3,5)/x(1)*wij(3,1) + y(10)*(set(3,1)+set(3,2)*x(2)^set(3,3))*set(3,5)/x(2)*wij(3,2) + y(11)*(set(3,1)+set(3,2)*x(3)^set(3,3))*set(3,5)/x(3)*wij(3,3) + y(12)*(set(3,1)+set(3,2)*x(4)^set(3,3))*set(3,5)/x(4)*wij(3,4);

%变量界限 (lb <= x <= ub)
lb = [0.1; 0.1; 0.1; 0.1; zeros(4,1)]; 
ub = [ones(4,1); Inf; Inf; Inf; Inf]; 
% 初始猜值
x0 = [1 1 1 1 0 0 0 0]';% x0 = [0.4954 0.5161 0.5402 0.6283 0 28.26 53.45 73.81]';
A = [];b = [];
Aeq = [];beq = [];
nonlcon  = @(x) nonlcon1111(x, DAG, choicePro, failureRate, set);
[xArr,fval,exitflag,output,lambda,grad,hessian] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon ); % 求解A·x≤b; Aeq·x=beq; lb≤x≤ub; c(x)≤0; ceq(x)=0 
end
