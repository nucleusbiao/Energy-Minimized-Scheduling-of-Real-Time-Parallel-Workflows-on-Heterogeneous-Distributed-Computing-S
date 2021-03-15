function sch=decode2(popin,info,data)

%第一段编码表示CPU分配，第二段编码表示优先级，第三段编码表示频率
%第一步，根据轮盘赌确定每一个任务的CPU分配
fp=zeros(1,info.n);
for i=1:info.n
    for j=1:info.m
        if (((j-1)/info.m)<popin(i))&&(popin(i)<(j/info.m))
            fp(i)=j;
            break
        else
            fp(i)=info.m;
        end
    end
end
%第二步，根据先后约束确定实际加工优先级
seq=zeros(1,info.n);
xh=data.xh;
hx=data.hx;
j=1;
[~,index]=sort(popin(info.n+1:2*info.n));
indexflag=zeros(1,info.n);
while j<info.n+1
    for i=1:info.n
        if all(xh(index(i),:)==0)&&(indexflag(i)==0)
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
%第三步，根据频率计算makespan和energy
%根据第三段编码与分配的CPU获取实际的功率值
f=zeros(1,info.n);
for i=1:info.n
    f(i)=popin(info.n*2+i)*(1-data.f(fp(i)))+data.f(fp(i));
end
%计算makespan
xh=data.xh;
mt=zeros(1,info.m);
st=zeros(1,info.n);%开始时间
dt=zeros(1,info.n);%结束时间
dn=zeros(1,info.n);%机器号
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

% em=max(mt)*data.pks;%各个机器的静态能耗
% e=sum(em);
sl = max(mt);
e = 0;
for i = 1:size(mt,2)
    if mt(i) > 1e-3
        e = e + sl*data.pks(i);
    end
end

each=zeros(1,info.n);
for i=1:info.n
    e=e+(data.p(dn(i))+data.c(dn(i))*f(i)^(data.mk(dn(i))))*(dt(i)-st(i));
%     e=e+(data.c(dn(i))*f(i)^(data.mk(dn(i))-1))*(dt(i)-st(i));
    each(i)=(data.p(dn(i))+data.c(dn(i))*f(i)^(data.mk(dn(i))))*(dt(i)-st(i));
%     each(i)=(data.c(dn(i))*f(i)^(data.mk(dn(i))-1))*(dt(i)-st(i));
end

sch.st=st; % 任务开始时间
sch.dt=dt; % 任务结束时间
sch.dn=dn; % 各任务分配的CPU号
sch.mt=mt; % 个CPU的完工时间
sch.e=e; % 总能量
sch.f=f; % 各个任务的频率
sch.pt=sch.dt-sch.st; % 执行时间
sch.eeach=each; % 每个任务的能量消耗