function data=setupData(info, Spec, NumLayer, TimeBound)
% 初始化Data
ELow=TimeBound(1,1); % 反应时间
EHigh=TimeBound(1,2);
data.st=zeros(info.n,info.n);
WcetLow=TimeBound(2,1); % 执行时间
WcetHigh=TimeBound(2,2);
data.ct=[];
PkindLow=TimeBound(3,1); % Pk,ind
PkindHigh=TimeBound(3,2);
CLow=TimeBound(4,1); % Ck,ef
CHigh=TimeBound(4,2);
mLow=TimeBound(5,1); % m,k
mHigh=TimeBound(5,2);
FmaxLow=TimeBound(6,1); % 最大频率
FmaxHigh=TimeBound(6,2);
FminLow=TimeBound(7,1); % 最小频率
FminHigh=TimeBound(7,2);
j=1; % 两个无实际意义的参数
g=2;

if Spec==0 % 这个if用来产生前序表和反应时间矩阵
    for i=1:NumLayer-1
        for k=j+1:j+NumLayer-i
            xharray(k,j)=j;
            data.st(j,k)=randi([ELow,EHigh],1);
        end
        j=j+1+NumLayer-i;
    end
    for i=1:NumLayer-2
        for k=1:NumLayer-i
            xharray(g+NumLayer-i,g)=g;
            data.st(g,g+NumLayer-i)=randi([ELow,EHigh],1);
            g=g+1;
        end
        g=g+1;
    end
elseif Spec==1
    for i = 0:1:log2(NumLayer)-1 % 给了上面的盖
        for j = 1:2^i
            xharray(2*(2^i+j-1), 2^i+j-1) = 2^i+j-1;
            xharray(2*(2^i+j-1)+1,2^i+j-1 ) = 2^i+j-1;
            data.st(2^i+j-1, 2*(2^i+j-1)) = randi([ELow,EHigh],1);
            data.st(2^i+j-1, 2*(2^i+j-1)+1) = randi([ELow,EHigh],1);
        end
    end
    for level = 1:log2(NumLayer) % 给出下面的主体
        StartNum = NumLayer*level;
        k=0;
        for i = 0:NumLayer-1 % 给出垂直的
            xharray(StartNum + i + NumLayer, StartNum + i) = StartNum + i;
            data.st(StartNum + i, StartNum + i + NumLayer) = randi([ELow,EHigh],1);
        end
        
        for i = 1:NumLayer/(2^level) % 给出斜着的
            for j=1:2^(level-1)
                xharray(StartNum + k + NumLayer + 2^(level-1), StartNum + k) = StartNum + k;
                xharray(StartNum + k + NumLayer, StartNum + k + 2^(level-1)) = StartNum + k + 2^(level-1);
                data.st(StartNum + k, StartNum + k + NumLayer + 2^(level-1)) = randi([ELow,EHigh],1);
                data.st(StartNum + k + 2^(level-1), StartNum + k + NumLayer) = randi([ELow,EHigh],1);
                k=k+1;
            end
            k=k+2^(level-1);
        end
    end
end
[imax,jmax]=size(xharray);
for i=1:imax
    m=1;
    for j=1:jmax
        if xharray(i,j)~=0
            data.xh(i,m)=j;
            m=m+1;
        end
    end
end
data.hx=getHx(data.xh); % 后序表

for i=1:info.n % 执行时间Wcet
    wcet_array_for_one = randi([WcetLow,WcetHigh],1,info.m); % 产生完成时间矩阵
    data.ct = [data.ct;wcet_array_for_one];
end
data.p=randi([round(PkindLow * 100), round(PkindHigh * 100)], 1, info.m) / 100; % 属于动态能量，可以通过让系统休眠来去除。Pk,ind
data.c=randi([CLow*10,CHigh*10],1,info.m)/10; % 系数C，动态能量中的β
data.mk=randi([mLow*10,mHigh*10],1,info.m)/10; % 动态能量中的指数mj
data.f=randi([FminLow * 100, FminHigh * 100],1,info.m) / 100; % 各个CPU的最小频率

data.pks=[0.01 0.01 0.01 0.01]; % 静态能量系数，可以通过关闭整个系统来去除

%% 自带的3处理器，10任务的初始化
% data.xh=[0 0 0; 1 0 0;1 0 0;
%     1 0 0;1 0 0; 1 0 0;
%     3 0 0;2 4 6; 2 4 5;
%     7 8 9];%先序矩阵
% data.hx=getHx(data.xh); % 后序表
% data.ct=[14 16 9; 13 19 18; 11 13 19;
%     13 8 17; 12 13 10; 13 16 9;
%     7 15 11; 5 11 14; 18 12 20; 21 7 16];
% %满频率计算时间，最大频率下任务i在CPUj上的计算时间。Wcet
% data.st=[0 18 12 9 11 14 0 0  0  0;
%     0 0  0  0 0  0 0  23 16 0;
%     0 0  0  0 0  0 23 0  0  0;
%     0 0  0  0 0  0 0  0  23 0;
%     0 0  0  0 0  0 0  0  13 0;
%     0 0  0  0 0  0 0  13 0  0;
%     0 0  0  0 0  0 0  0  0  17;
%     0 0  0  0 0  0 0  0  0  11;
%     0 0  0  0 0  0 0  0  0  13;
%     0 0  0  0 0  0 0  0  0  0];%整定时间(传输时间？)，反应时间E
% data.f=[0.19 0.32 0.46];%各个CPU的最小频率
% data.c=[1.3 0.5 0.2];%系数C，动态能量中的β
% data.p=[0.02 0.05 0.04];%恒定功率p，属于动态能量，可以通过让系统休眠来去除
% data.mk=[2.9 2.1 3.0]; % 动态能量中的指数mj
% data.pks=[0.01 0.01 0.01]; % 静态能量系数，可以通过关闭整个系统来去除