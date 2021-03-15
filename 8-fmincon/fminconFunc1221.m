function [xArr,fval,exitflag,output,lambda,grad,hessian] = fminconFunc1221(choicePro, DAG, failureRate, set, d)
taskNum = size(DAG.Wcet, 2) - 1;
proNum = size(DAG.Wcet, 1);
y = zeros(1, taskNum*proNum);
for i = 1:size(choicePro, 2) %公式10
    y(i+(choicePro(i)-1)*taskNum) = 1;
end
wij = DAG.Wcet(:,1:taskNum); %执行时间

% 优化目标
% fun = @(x) y(1)*(set(1,1)+set(1,2)*x(1)^set(1,3))*set(1,5)/x(1)*wij(1,1) + y(2)*(set(1,1)+set(1,2)*x(2)^set(1,3))*set(1,5)/x(2)*wij(1,2) + y(3)*(set(1,1)+set(1,2)*x(3)^set(1,3))*set(1,5)/x(3)*wij(1,3) + y(4)*(set(1,1)+set(1,2)*x(4)^set(1,3))*set(1,5)/x(4)*wij(1,4) + y(5)*(set(1,1)+set(1,2)*x(5)^set(1,3))*set(1,5)/x(5)*wij(1,5) + y(6)*(set(1,1)+set(1,2)*x(6)^set(1,3))*set(1,5)/x(6)*wij(1,6) ...
%     + y(7)*(set(2,1)+set(2,2)*x(1)^set(2,3))*set(2,5)/x(1)*wij(2,1) + y(8)*(set(2,1)+set(2,2)*x(2)^set(2,3))*set(2,5)/x(2)*wij(2,2) + y(9)*(set(2,1)+set(2,2)*x(3)^set(2,3))*set(2,5)/x(3)*wij(2,3) + y(10)*(set(2,1)+set(2,2)*x(4)^set(2,3))*set(2,5)/x(4)*wij(2,4) + y(11)*(set(2,1)+set(2,2)*x(5)^set(2,3))*set(2,5)/x(5)*wij(2,5) + y(12)*(set(2,1)+set(2,2)*x(6)^set(2,3))*set(2,5)/x(6)*wij(2,6) ...
%     + y(13)*(set(3,1)+set(3,2)*x(1)^set(3,3))*set(3,5)/x(1)*wij(3,1) + y(14)*(set(3,1)+set(3,2)*x(2)^set(3,3))*set(3,5)/x(2)*wij(3,2) + y(15)*(set(3,1)+set(3,2)*x(3)^set(3,3))*set(3,5)/x(3)*wij(3,3) + y(16)*(set(3,1)+set(3,2)*x(4)^set(3,3))*set(3,5)/x(4)*wij(3,4) + y(17)*(set(3,1)+set(3,2)*x(5)^set(3,3))*set(3,5)/x(5)*wij(3,5) + y(18)*(set(3,1)+set(3,2)*x(6)^set(3,3))*set(3,5)/x(6)*wij(3,6) ...
%     + y(19)*(set(4,1)+set(4,2)*x(1)^set(4,3))*set(4,5)/x(1)*wij(4,1) + y(20)*(set(4,1)+set(4,2)*x(2)^set(4,3))*set(4,5)/x(2)*wij(4,2) + y(21)*(set(4,1)+set(4,2)*x(3)^set(4,3))*set(4,5)/x(3)*wij(4,3) + y(22)*(set(4,1)+set(4,2)*x(4)^set(4,3))*set(4,5)/x(4)*wij(4,4) + y(23)*(set(4,1)+set(4,2)*x(5)^set(4,3))*set(4,5)/x(5)*wij(4,5) + y(24)*(set(4,1)+set(4,2)*x(6)^set(4,3))*set(4,5)/x(6)*wij(4,6);

fun = @(x) y(1)*set(1,2)*x(1)^set(1,3) *set(1,5)/x(1)*wij(1,1) + y(2)*set(1,2)*x(2)^set(1,3) *set(1,5)/x(2)*wij(1,2) + y(3)*set(1,2)*x(3)^set(1,3) *set(1,5)/x(3)*wij(1,3) + y(4)*set(1,2)*x(4)^set(1,3) *set(1,5)/x(4)*wij(1,4) + y(5)*set(1,2)*x(5)^set(1,3) *set(1,5)/x(5)*wij(1,5) + y(6)*set(1,2)*x(6)^set(1,3) *set(1,5)/x(6)*wij(1,6) ...
    + y(7)*set(2,2)*x(1)^set(2,3) *set(2,5)/x(1)*wij(2,1) + y(8)*set(2,2)*x(2)^set(2,3) *set(2,5)/x(2)*wij(2,2) + y(9)*set(2,2)*x(3)^set(2,3)*set(2,5)/x(3)*wij(2,3) + y(10)*set(2,2)*x(4)^set(2,3) *set(2,5)/x(4)*wij(2,4) + y(11)*set(2,2)*x(5)^set(2,3) *set(2,5)/x(5)*wij(2,5) + y(12)*set(2,2)*x(6)^set(2,3) *set(2,5)/x(6)*wij(2,6) ...
    + y(13)*set(3,2)*x(1)^set(3,3) *set(3,5)/x(1)*wij(3,1) + y(14)*set(3,2)*x(2)^set(3,3) *set(3,5)/x(2)*wij(3,2) + y(15)*set(3,2)*x(3)^set(3,3) *set(3,5)/x(3)*wij(3,3) + y(16)*set(3,2)*x(4)^set(3,3) *set(3,5)/x(4)*wij(3,4) + y(17)*set(3,2)*x(5)^set(3,3) *set(3,5)/x(5)*wij(3,5) + y(18)*set(3,2)*x(6)^set(3,3) *set(3,5)/x(6)*wij(3,6) ...
    + y(19)*set(4,2)*x(1)^set(4,3) *set(4,5)/x(1)*wij(4,1) + y(20)*+set(4,2)*x(2)^set(4,3) *set(4,5)/x(2)*wij(4,2) + y(21)*set(4,2)*x(3)^set(4,3) *set(4,5)/x(3)*wij(4,3) + y(22)*set(4,2)*x(4)^set(4,3) *set(4,5)/x(4)*wij(4,4) + y(23)*set(4,2)*x(5)^set(4,3) *set(4,5)/x(5)*wij(4,5) + y(24)*set(4,2)*x(6)^set(4,3) *set(4,5)/x(6)*wij(4,6) ...
    + (max([y(1),y(2),y(3),y(4),y(5),y(6)])*set(1,1)+max([y(7),y(8),y(9),y(10),y(11),y(12)])*set(2,1)+max([y(13),y(14),y(15),y(16),y(17),y(18)])*set(3,1)+max([y(19),y(20),y(21),y(22),y(23),y(24)])*set(4,1))*max([y(1)*(x(7)+wij(1,1)/x(1)), y(2)*(x(8)+wij(1,2)/x(2)), y(3)*(x(9)+wij(1,3)/x(3)), y(4)*(x(10)+wij(1,4)/x(4)), y(5)*(x(11)+wij(1,5)/x(5)), y(6)*(x(12)+wij(1,6)/x(6)), y(7)*(x(7)+wij(2,1)/x(1)), y(8)*(x(8)+wij(2,2)/x(2)), y(9)*(x(9)+wij(2,3)/x(3)), y(10)*(x(10)+wij(2,4)/x(4)), y(11)*(x(11)+wij(2,5)/x(5)), y(12)*(x(12)+wij(2,6)/x(6)), y(13)*(x(7)+wij(3,1)/x(1)), y(14)*(x(8)+wij(3,2)/x(2)), y(15)*(x(9)+wij(3,3)/x(3)), y(16)*(x(10)+wij(3,4)/x(4)), y(17)*(x(11)+wij(3,5)/x(5)), y(18)*(x(12)+wij(3,6)/x(6)), y(19)*(x(7)+wij(4,1)/x(1)), y(20)*(x(8)+wij(4,2)/x(2)), y(21)*(x(9)+wij(4,3)/x(3)), y(22)*(x(10)+wij(4,4)/x(4)), y(23)*(x(11)+wij(4,5)/x(5)), y(24)*(x(12)+wij(4,6)/x(6))]);

%变量界限 (lb <= x <= ub)
lb = [ones(taskNum,1)*set(1,4); zeros(taskNum,1)]; %频率、开始时间的下限约束
ub = [ones(taskNum,1)*set(1,5); Inf; Inf; Inf; Inf; Inf; Inf]; %频率、开始时间的上限约束

x0 = [1 1 1 1 1 1 0 0 0 0 0 0]';% x的初始值
A = [];b = [];
Aeq = [];beq = [];
nonlcon  = @(x) nonlconGeneral(x, DAG, choicePro, failureRate, set, d);
[xArr,fval,exitflag,output,lambda,grad,hessian] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon ); % 求解A·x≤b; Aeq·x=beq; lb≤x≤ub; c(x)≤0; ceq(x)=0 
end