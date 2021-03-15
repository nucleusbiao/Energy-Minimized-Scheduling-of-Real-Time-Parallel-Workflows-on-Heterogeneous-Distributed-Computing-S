function Opt = OPTI(choicePro, DAG, failureRate, set)
taskNum = size(DAG.Wcet, 2) - 1;
proNum = size(DAG.Wcet, 1);
y = zeros(1, taskNum*proNum);
d = 3;
fmax = set(:,5)';
fmin = set(:,4)';
wij = DAG.Wcet(:,1:taskNum);
for i = 1:size(choicePro, 2) %��ʽ10
    y(i+(choicePro(i)-1)*taskNum) = 1;
end

fun = @(x) y(1)*(0.06+0.8*x(1)^2.9)*1/x(1)*14 + y(2)*(0.06+0.8*x(2)^2.9)*1/x(2)*13 + y(3)*(0.06+0.8*x(3)^2.9)*1/x(3)*11 + y(4)*(0.06+0.8*x(4)^2.9)*1/x(4)*13 ...
    + y(5)*(0.07+1.2*x(1)^2.7)*1/x(1)*16 + y(6)*(0.07+1.2*x(2)^2.7)*1/x(2)*19 + y(7)*(0.07+1.2*x(3)^2.7)*1/x(3)*13 + y(8)*(0.07+1.2*x(4)^2.7)*1/x(4)*8 ...
    + y(9)*(0.07+1*x(1)^2.4)*1/x(1)*9 + y(10)*(0.07+1*x(2)^2.4)*1/x(2)*18 + y(11)*(0.07+1*x(3)^2.4)*1/x(3)*19 + y(12)*(0.07+1*x(4)^2.4)*1/x(4)*17;

% xtype = 'IIIIIIIIIIIICCCCCCCC'; %ȫΪ����--��Ҫ˵���£�I����interger C����ʵ��  B ����{0��1��
% Լ������ (cl <= nlcon(x) <= cu) ������cons�Ӻ�����
nlcon = @(x) [ 
    x(6)-(x(5)+ (y(1)*14/x(1)+1/2*abs(y(1)-y(2))*18 +y(5)*16/x(1)+1/2*abs(y(5)-y(6))*18 +y(9)*9/x(1)+1/2*abs(y(9)-y(10))*18) ); %��ʽ11-���ȼ���ִ��˳��
    x(7)-(x(6)+ (y(2)*13/x(2)+1/2*abs(y(2)-y(3))*12 +y(6)*19/x(2)+1/2*abs(y(6)-y(7))*12 +y(10)*18/x(2)+1/2*abs(y(10)-y(11))*12) );
    x(8)-(x(7)+ (y(3)*11/x(3)+1/2*abs(y(3)-y(4))*9 +y(7)*13/x(3)+1/2*abs(y(7)-y(8))*9 +y(10)*19/x(3)+1/2*abs(y(11)-y(12))*9) );
    
    (y(1)*y(2)+y(5)*y(6)+y(9)*y(10)) * (x(5)+ (y(1)*14/x(1)+y(5)*16/x(1)+y(9)*9/x(1)) -x(6)) * (x(6)+ (y(2)*13/x(2)+y(6)*19/x(2)+y(10)*18/x(2)) -x(5)); %��ʽ12-�����������ִ��ʱ�䲻����ͬһ�����������ص�
    (y(1)*y(3)+y(5)*y(7)+y(9)*y(11)) * (x(5)+ (y(1)*14/x(1)+y(5)*16/x(1)+y(9)*9/x(1)) -x(7)) * (x(7)+ (y(3)*11/x(3)+y(7)*13/x(3)+y(11)*19/x(3)) -x(5));
    (y(1)*y(4)+y(5)*y(8)+y(9)*y(12)) * (x(5)+ (y(1)*14/x(1)+y(5)*16/x(1)+y(9)*9/x(1)) -x(8)) * (x(8)+ (y(4)*13/x(4)+y(8)*8/x(4)+y(12)*17/x(4)) -x(5));
    (y(2)*y(3)+y(6)*y(7)+y(10)*y(11)) * (x(6)+ (y(2)*13/x(2)+y(6)*19/x(2)+y(10)*18/x(2)) -x(7)) * (x(7)+ (y(3)*11/x(3)+y(7)*13/x(3)+y(11)*19/x(3)) -x(6));
    (y(2)*y(4)+y(6)*y(8)+y(10)*y(12)) * (x(6)+ (y(2)*13/x(2)+y(6)*19/x(2)+y(10)*18/x(2)) -x(8)) * (x(8)+ (y(4)*13/x(4)+y(8)*8/x(4)+y(12)*17/x(4)) -x(6));
    (y(3)*y(4)+y(7)*y(8)+y(11)*y(12)) * (x(7)+ (y(3)*11/x(3)+y(7)*13/x(3)+y(11)*19/x(3)) -x(8)) * (x(8)+ (y(4)*13/x(4)+y(8)*8/x(4)+y(12)*17/x(4)) -x(7));
    
    x(8)+(y(4)*13/x(4)+ y(8)*8/x(4)+ y(12)*17/x(4)); %��ʽ13-�����ֹʱ��Լ��
    
    (y(1)*exp(1)^(-failureRate(1)*10^(d*(fmax(1)-x(1))/(fmax(1)-fmin(1)))*(wij(1,1)*fmax(1))/x(1)) +y(5)*exp(1)^(-failureRate(2)*10^(d*(fmax(2)-x(1))/(fmax(2)-fmin(2)))*(wij(2,1)*fmax(2))/x(1)) +y(9)*exp(1)^(-failureRate(3)*10^(d*(fmax(3)-x(1))/(fmax(3)-fmin(3)))*(wij(3,1)*fmax(3))/x(1)))* ...
    (y(2)*exp(1)^(-failureRate(1)*10^(d*(fmax(1)-x(2))/(fmax(1)-fmin(1)))*(wij(1,2)*fmax(1))/x(2)) +y(6)*exp(1)^(-failureRate(2)*10^(d*(fmax(2)-x(2))/(fmax(2)-fmin(2)))*(wij(2,2)*fmax(2))/x(2)) +y(10)*exp(1)^(-failureRate(3)*10^(d*(fmax(3)-x(2))/(fmax(3)-fmin(3)))*(wij(3,2)*fmax(3))/x(2)))* ...
    (y(3)*exp(1)^(-failureRate(1)*10^(d*(fmax(1)-x(3))/(fmax(1)-fmin(1)))*(wij(1,3)*fmax(1))/x(3)) +y(7)*exp(1)^(-failureRate(2)*10^(d*(fmax(2)-x(3))/(fmax(2)-fmin(2)))*(wij(2,3)*fmax(2))/x(3)) +y(11)*exp(1)^(-failureRate(3)*10^(d*(fmax(3)-x(3))/(fmax(3)-fmin(3)))*(wij(3,3)*fmax(3))/x(3)))* ...
    (y(4)*exp(1)^(-failureRate(1)*10^(d*(fmax(1)-x(4))/(fmax(1)-fmin(1)))*(wij(1,4)*fmax(1))/x(4)) +y(8)*exp(1)^(-failureRate(2)*10^(d*(fmax(2)-x(4))/(fmax(2)-fmin(2)))*(wij(2,4)*fmax(2))/x(4)) +y(12)*exp(1)^(-failureRate(3)*10^(d*(fmax(3)-x(4))/(fmax(3)-fmin(3)))*(wij(3,4)*fmax(3))/x(4)))%��ʽ14-����ɿ���Լ��
    ];

cl = [0;  0;  0;    -Inf;-Inf;-Inf;-Inf;-Inf;-Inf;  0;                     DAG.relReq]; %Լ����������Сֵ
cu = [Inf;Inf;Inf;  0;   0;   0;   0;   0;   0;     DAG.relativeDeadline;  1]; %Լ�����������ֵ������ǵ������С�ڻ��ߴ��������� Inf��ʽ


%�������� (lb <= x <= ub)
lb = [0.1; 0.1; 0.1; 0.1; zeros(4,1)]; 
ub = [ones(4,1); Inf; Inf; Inf; Inf];  
% ��ʼ��ֵ
x0 = [1 1 1 1 0 0 0 0]';
% �������
opts = optiset('solver','ipopt','display','iter');
%��������
Opt = opti('fun',fun,'nl',nlcon,cl,cu,'bounds',lb,ub,'x0',x0,'options',opts)
end