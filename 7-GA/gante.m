function gante(sch,info)

dt=sch.dt;
st=sch.st;
dn=sch.dn;
mt=sch.mt;
e=sch.e;

figure(1)
axis([0,max(dt)+1,0,info.m+0.5]);%x�� y��ķ�Χ
%set(gca,'xtick',0:cell((max(dt)+1)/10):max(dt)+1);%x�����������
set(gca,'ytick',0:1:info.m+0.5) ;%y�����������
xlabel('ʱ��'),ylabel('ECU��');%x�� y�������
temp=['makespanΪ',num2str(max(mt)),'�ĵ��ȷ�������������Ϊ��',num2str(e)];
title(temp);%ͼ�εı���

n_task_nb =sum(info.n);%total tasks  //������Ŀ
%x�� ��Ӧ�ڻ�ͼλ�õ���ʼ����x
n_start_time=st;%start time of every task  //ÿһ��������_ʼʱ��
%length ��Ӧ��ÿһ��ͼ����x�᷽��ĳ���
n_duration_time =dt-st;%duration time of every task  //ÿһ������ĳ���ʱ��
%y�� ��Ӧ�ڻ�ͼλ�õ���ʼ����y
n_bay_start=dn-1; %bay id of every task  ==������Ŀ��������һ�л���
%����ţ��ܹ����ݹ����ѡ��ʹ����һ����ɫ
lx=1:info.n;
n_job_id=lx;%
n_fid=zeros(1,info.n);
n_fid(1)=1;
for i=2:info.n
    if lx(i)==lx(i-1)
        n_fid(i)=n_fid(i-1)+1;
    elseif lx(i)-lx(i-1)==1
        n_fid(i)=1;
    else
        error('���ݴ���');
    end
end
rec=[0,0,0,0];%temp data space for every rectangle  
%color=['r','g','b','c','m','y'];
for i =1:n_task_nb  
    rec(1) = n_start_time(i);%���εĺ�����
    rec(2) = n_bay_start(i)+0.7;  %���ε�������
    rec(3) = n_duration_time(i);  %���ε�x�᷽��ĳ���
    rec(4) = 0.6;
    txt=sprintf('%d,%d',n_fid(i),lx(i));
    rectangle('Position',rec,'LineWidth',0.5,'LineStyle','-','FaceColor','w');%draw every rectangle  
    text(n_start_time(i)+0.2,(n_bay_start(i)+1),txt,'FontWeight','Bold','FontSize',14);%label the id of every task  ��������������������
end  