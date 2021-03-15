function [fit,able,fadv]=decode(popin,info,data,failureRate,relReq,d)

relTotal=1;
reliTask1=[];
%第一段编码表示CPU分配，第二段编码表示任务排序优先级，第三段编码表示频率
%第一步，根据轮盘赌确定每一个任务的CPU分配
fp=zeros(1,info.n);
gapCpu = 1/info.m; % 作为间隔，来分配任务到CPU
for i=1:info.n % 把每个任务分配到CPU中，然后把CPU号存到fp中
    gapCpuLow = 0;
    for j = 1:info.m
        if (popin(i)>gapCpuLow)&&(popin(i)<=gapCpuLow+gapCpu)
            fp(i) = j;
            break
        end
        gapCpuLow = gapCpuLow + gapCpu;
    end
end
%第二步，根据先后约束确定实际加工优先级
seq=zeros(1,info.n);
xh=data.xh; % 先序矩阵
hx=data.hx; % 后序表
j=1;
[~,index]=sort(popin(info.n+1:2*info.n)); % 把pop中第10到第20列按从小到大排序，并把编号存起来
indexflag=zeros(1,info.n);
while j<info.n+1 % 对当前可以执行（先序全部完成）的任务，进行排序，存在seq中。
    for i=1:info.n
        if all(xh(index(i),:)==0)&&(indexflag(i)==0) % 当取到xh的第一行时，才运行下面的句子
            seq(j)=index(i);
            j=j+1;
            indexflag(i)=1;
            for k=1:size(hx,2)
                for l=1:size(xh,2)
                    if hx(index(i),k)~=0
                        if xh(hx(index(i),k),l)==index(i)
                            xh(hx(index(i),k),l)=0;
                            break
                        end
                    end
                end
            end
        end
    end
end
% seq = DAG.priority_order;
%第三步，根据频率计算makespan和energy
%根据第三段编码与分配的CPU获取实际的功率值
f=zeros(1,info.n);%频率
for i=1:info.n
    f(i)=popin(info.n*2+i)*(1-data.f(fp(i)))+data.f(fp(i)); % 将0-1的实数归一化到对应CPU最小频率到1之间，作为频率。
end
%计算makespan
xh=data.xh;
mt=zeros(1,info.m); % 每个CPU的调度时长
st=zeros(1,info.n); % 开始时间
dt=zeros(1,info.n); % 结束时间
dn=zeros(1,info.n); % 机器号
for i=1:info.n
    curr=seq(i);
    dn(curr)=fp(curr);
    %开始时间为机器时间与(前置完成时间+可能存在的整定时间)中的最大值
    temp=find(xh(curr,:)>0);
    if ~isempty(temp)%存在前置
        tst=zeros(1,length(temp));
        for j=1:length(temp)
            if dn(curr)~=dn(xh(curr,j))
                tst(j)=dt(xh(curr,j))+data.st(xh(curr,j),curr);
            else
                tst(j)=dt(xh(curr,j));
            end
        end
    end
    if ~isempty(temp)
        tlast=max(tst);
    else
        tlast=0;
    end
    st(curr)=max(mt(fp(curr)),tlast);
    dt(curr)=st(curr)+data.ct(curr,dn(curr))/f(curr);
    mt(fp(curr))=dt(curr);
end

% 计算可靠性约束是否被满足
for i=1:info.n
    reliTask=exp(-(failureRate(dn(i))*10^(d*(1-f(i))/(1-data.f(dn(i))))*(dt(i)-st(i))));
    reliTask1=[reliTask1,reliTask];
    relTotal=relTotal*reliTask1(i);
end

% 适应度函数：适应度函数由能量函数与惩罚项组成
if max(mt)>info.cmax
    able=1;
else
    able=0;
end

% em=max(mt)*data.pks;%各个机器的静态能耗
% e=sum(em);
sl = max(mt);
e = 0;
for i = 1:size(mt,2)
    if mt(i) > 1e-3
        e = e + sl*data.pks(i);
    end
end

for i=1:info.n
    e=e+((data.p(dn(i))+data.c(dn(i))*f(i)^(data.mk(dn(i))))*(dt(i)-st(i))); % 能量函数
end
fadv=zeros(1,info.n);%如果频率大于0.9990建议改为1x
for i=1:info.n
    if popin(info.n*2+i)>=0.999
        fadv(i)=1;
    end
end
%计算各个CPU的能量
if max(mt)-info.cmax>0
    fit=1e20; % 惩罚函数，超时*10+惩罚项40
else
    fit=e;
end
if relTotal<relReq
    fit=1e20; % 惩罚函数，如果不满足可靠性就给1000惩罚值
end
