function data=setupData(info, Spec, NumLayer, TimeBound)
% ��ʼ��Data
ELow=TimeBound(1,1); % ��Ӧʱ��
EHigh=TimeBound(1,2);
data.st=zeros(info.n,info.n);
WcetLow=TimeBound(2,1); % ִ��ʱ��
WcetHigh=TimeBound(2,2);
data.ct=[];
PkindLow=TimeBound(3,1); % Pk,ind
PkindHigh=TimeBound(3,2);
CLow=TimeBound(4,1); % Ck,ef
CHigh=TimeBound(4,2);
mLow=TimeBound(5,1); % m,k
mHigh=TimeBound(5,2);
FmaxLow=TimeBound(6,1); % ���Ƶ��
FmaxHigh=TimeBound(6,2);
FminLow=TimeBound(7,1); % ��СƵ��
FminHigh=TimeBound(7,2);
j=1; % ������ʵ������Ĳ���
g=2;

if Spec==0 % ���if��������ǰ���ͷ�Ӧʱ�����
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
    for i = 0:1:log2(NumLayer)-1 % ��������ĸ�
        for j = 1:2^i
            xharray(2*(2^i+j-1), 2^i+j-1) = 2^i+j-1;
            xharray(2*(2^i+j-1)+1,2^i+j-1 ) = 2^i+j-1;
            data.st(2^i+j-1, 2*(2^i+j-1)) = randi([ELow,EHigh],1);
            data.st(2^i+j-1, 2*(2^i+j-1)+1) = randi([ELow,EHigh],1);
        end
    end
    for level = 1:log2(NumLayer) % �������������
        StartNum = NumLayer*level;
        k=0;
        for i = 0:NumLayer-1 % ������ֱ��
            xharray(StartNum + i + NumLayer, StartNum + i) = StartNum + i;
            data.st(StartNum + i, StartNum + i + NumLayer) = randi([ELow,EHigh],1);
        end
        
        for i = 1:NumLayer/(2^level) % ����б�ŵ�
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
data.hx=getHx(data.xh); % �����

for i=1:info.n % ִ��ʱ��Wcet
    wcet_array_for_one = randi([WcetLow,WcetHigh],1,info.m); % �������ʱ�����
    data.ct = [data.ct;wcet_array_for_one];
end
data.p=randi([round(PkindLow * 100), round(PkindHigh * 100)], 1, info.m) / 100; % ���ڶ�̬����������ͨ����ϵͳ������ȥ����Pk,ind
data.c=randi([CLow*10,CHigh*10],1,info.m)/10; % ϵ��C����̬�����еĦ�
data.mk=randi([mLow*10,mHigh*10],1,info.m)/10; % ��̬�����е�ָ��mj
data.f=randi([FminLow * 100, FminHigh * 100],1,info.m) / 100; % ����CPU����СƵ��

data.pks=[0.01 0.01 0.01 0.01]; % ��̬����ϵ��������ͨ���ر�����ϵͳ��ȥ��

%% �Դ���3��������10����ĳ�ʼ��
% data.xh=[0 0 0; 1 0 0;1 0 0;
%     1 0 0;1 0 0; 1 0 0;
%     3 0 0;2 4 6; 2 4 5;
%     7 8 9];%�������
% data.hx=getHx(data.xh); % �����
% data.ct=[14 16 9; 13 19 18; 11 13 19;
%     13 8 17; 12 13 10; 13 16 9;
%     7 15 11; 5 11 14; 18 12 20; 21 7 16];
% %��Ƶ�ʼ���ʱ�䣬���Ƶ��������i��CPUj�ϵļ���ʱ�䡣Wcet
% data.st=[0 18 12 9 11 14 0 0  0  0;
%     0 0  0  0 0  0 0  23 16 0;
%     0 0  0  0 0  0 23 0  0  0;
%     0 0  0  0 0  0 0  0  23 0;
%     0 0  0  0 0  0 0  0  13 0;
%     0 0  0  0 0  0 0  13 0  0;
%     0 0  0  0 0  0 0  0  0  17;
%     0 0  0  0 0  0 0  0  0  11;
%     0 0  0  0 0  0 0  0  0  13;
%     0 0  0  0 0  0 0  0  0  0];%����ʱ��(����ʱ�䣿)����Ӧʱ��E
% data.f=[0.19 0.32 0.46];%����CPU����СƵ��
% data.c=[1.3 0.5 0.2];%ϵ��C����̬�����еĦ�
% data.p=[0.02 0.05 0.04];%�㶨����p�����ڶ�̬����������ͨ����ϵͳ������ȥ��
% data.mk=[2.9 2.1 3.0]; % ��̬�����е�ָ��mj
% data.pks=[0.01 0.01 0.01]; % ��̬����ϵ��������ͨ���ر�����ϵͳ��ȥ��