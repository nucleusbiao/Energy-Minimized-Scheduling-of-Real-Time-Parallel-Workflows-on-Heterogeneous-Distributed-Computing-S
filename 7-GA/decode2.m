function sch=decode2(popin,info,data)

%��һ�α����ʾCPU���䣬�ڶ��α����ʾ���ȼ��������α����ʾƵ��
%��һ�����������̶�ȷ��ÿһ�������CPU����
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
%�ڶ����������Ⱥ�Լ��ȷ��ʵ�ʼӹ����ȼ�
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
%������������Ƶ�ʼ���makespan��energy
%���ݵ����α���������CPU��ȡʵ�ʵĹ���ֵ
f=zeros(1,info.n);
for i=1:info.n
    f(i)=popin(info.n*2+i)*(1-data.f(fp(i)))+data.f(fp(i));
end
%����makespan
xh=data.xh;
mt=zeros(1,info.m);
st=zeros(1,info.n);%��ʼʱ��
dt=zeros(1,info.n);%����ʱ��
dn=zeros(1,info.n);%������
for i=1:info.n
    curr=seq(i);
    dn(curr)=fp(curr);
    %��ʼʱ��Ϊ����ʱ����(ǰ�����ʱ��+���ܴ��ڵ�����ʱ��)�е����ֵ
    temp=find(xh(curr,:)>0);
    if ~isempty(temp)%����ǰ��
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

% em=max(mt)*data.pks;%���������ľ�̬�ܺ�
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

sch.st=st; % ����ʼʱ��
sch.dt=dt; % �������ʱ��
sch.dn=dn; % ����������CPU��
sch.mt=mt; % ��CPU���깤ʱ��
sch.e=e; % ������
sch.f=f; % ���������Ƶ��
sch.pt=sch.dt-sch.st; % ִ��ʱ��
sch.eeach=each; % ÿ���������������