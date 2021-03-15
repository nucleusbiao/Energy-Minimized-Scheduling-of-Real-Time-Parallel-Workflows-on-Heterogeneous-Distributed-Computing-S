function [fit,able,fadv]=decode(popin,info,data,failureRate,relReq,d)

relTotal=1;
reliTask1=[];
%��һ�α����ʾCPU���䣬�ڶ��α����ʾ�����������ȼ��������α����ʾƵ��
%��һ�����������̶�ȷ��ÿһ�������CPU����
fp=zeros(1,info.n);
gapCpu = 1/info.m; % ��Ϊ���������������CPU
for i=1:info.n % ��ÿ��������䵽CPU�У�Ȼ���CPU�Ŵ浽fp��
    gapCpuLow = 0;
    for j = 1:info.m
        if (popin(i)>gapCpuLow)&&(popin(i)<=gapCpuLow+gapCpu)
            fp(i) = j;
            break
        end
        gapCpuLow = gapCpuLow + gapCpu;
    end
end
%�ڶ����������Ⱥ�Լ��ȷ��ʵ�ʼӹ����ȼ�
seq=zeros(1,info.n);
xh=data.xh; % �������
hx=data.hx; % �����
j=1;
[~,index]=sort(popin(info.n+1:2*info.n)); % ��pop�е�10����20�а���С�������򣬲��ѱ�Ŵ�����
indexflag=zeros(1,info.n);
while j<info.n+1 % �Ե�ǰ����ִ�У�����ȫ����ɣ������񣬽������򣬴���seq�С�
    for i=1:info.n
        if all(xh(index(i),:)==0)&&(indexflag(i)==0) % ��ȡ��xh�ĵ�һ��ʱ������������ľ���
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
%������������Ƶ�ʼ���makespan��energy
%���ݵ����α���������CPU��ȡʵ�ʵĹ���ֵ
f=zeros(1,info.n);%Ƶ��
for i=1:info.n
    f(i)=popin(info.n*2+i)*(1-data.f(fp(i)))+data.f(fp(i)); % ��0-1��ʵ����һ������ӦCPU��СƵ�ʵ�1֮�䣬��ΪƵ�ʡ�
end
%����makespan
xh=data.xh;
mt=zeros(1,info.m); % ÿ��CPU�ĵ���ʱ��
st=zeros(1,info.n); % ��ʼʱ��
dt=zeros(1,info.n); % ����ʱ��
dn=zeros(1,info.n); % ������
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

% ����ɿ���Լ���Ƿ�����
for i=1:info.n
    reliTask=exp(-(failureRate(dn(i))*10^(d*(1-f(i))/(1-data.f(dn(i))))*(dt(i)-st(i))));
    reliTask1=[reliTask1,reliTask];
    relTotal=relTotal*reliTask1(i);
end

% ��Ӧ�Ⱥ�������Ӧ�Ⱥ���������������ͷ������
if max(mt)>info.cmax
    able=1;
else
    able=0;
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

for i=1:info.n
    e=e+((data.p(dn(i))+data.c(dn(i))*f(i)^(data.mk(dn(i))))*(dt(i)-st(i))); % ��������
end
fadv=zeros(1,info.n);%���Ƶ�ʴ���0.9990�����Ϊ1x
for i=1:info.n
    if popin(info.n*2+i)>=0.999
        fadv(i)=1;
    end
end
%�������CPU������
if max(mt)-info.cmax>0
    fit=1e20; % �ͷ���������ʱ*10+�ͷ���40
else
    fit=e;
end
if relTotal<relReq
    fit=1e20; % �ͷ����������������ɿ��Ծ͸�1000�ͷ�ֵ
end
