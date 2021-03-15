function []=newGantePerTask(in, frequencyArray)

leng = 0.7;
num=length(fieldnames(in));%��ȡECU����
for i=1:num
    temp=['ecu{i}=in.processor',num2str(i),';'];
    eval(temp);
end
task=0;
for i=1:num
    task=task+size(ecu{i},1);
end
i=1;
st=zeros(1,task);
dt=zeros(1,task);
%lx=zeros(1,task);
n_fid=zeros(1,task);
dn=zeros(1,task);
for j=1:num
    for k=1:size(ecu{j},1)
        st(i)=ecu{j}(k,1);
        dt(i)=ecu{j}(k,3);
        %lx(i)=ecu{j}(k,3);
        n_fid(i)=ecu{j}(k,5);
        dn(i)=j;
        i=i+1;
    end
end
        
axis([0,max(dt)+1,0,num+0.5]);%x�� y��ķ�Χ
%set(gca,'xtick',0:cell((max(dt)+1)/10):max(dt)+1);%x�����������
set(gca,'ytick',0:1:num+0.5) ;%y�����������
xlabel('Time'),ylabel('Processor');%x�� y�������
% temp=['�깤ʱ��Ϊ',num2str(max(dt)),'�ĵ��ȷ���'];
% title(temp);%ͼ�εı���

n_task_nb =task;%total tasks  //������Ŀ
%x�� ��Ӧ�ڻ�ͼλ�õ���ʼ����x
n_start_time=st;%start time of every task  //ÿһ��������_ʼʱ��
%length ��Ӧ��ÿһ��ͼ����x�᷽��ĳ���
n_duration_time =dt-st;%duration time of every task  //ÿһ������ĳ���ʱ��
%y�� ��Ӧ�ڻ�ͼλ�õ���ʼ����y
n_bay_start=dn-1; %bay id of every task  ==�����ţ�������һ�л���
%����ţ��ܹ����ݹ����ѡ��ʹ����һ����ɫ
for i = 1:num
    rectangle('Position',[0,leng,max(dt),0.6],'LineWidth',1,'LineStyle','-','FaceColor','white');%draw every rectangle
    leng = leng+1;
end

rec=[0,0,0,0];%temp data space for every rectangle
color=['g','b','r','c','m','y'];
for i =1:n_task_nb
    rec(1) = n_start_time(i);%���εĺ�����
    rec(2) = n_bay_start(i)+0.7;  %���ε�������
    rec(3) = n_duration_time(i);  %���ε�x�᷽��ĳ���
    rec(4) = 0.6*frequencyArray(n_fid(i));
    %txt=sprintf('$T_{%d}$',n_fid(i));
    txt=sprintf('%d',n_fid(i));
    rectangle('Position',rec,'LineWidth',1,'LineStyle','-','FaceColor',color(6));%draw every rectangle
    %text(n_start_time(i)+0.2,(n_bay_start(i)+1),txt,'Color', 'black', 'Interpreter', 'latex','FontWeight','Bold','FontSize',14);%label the id of every task  ��������������������
    text(n_start_time(i)+0.2,(n_bay_start(i)+1),txt, 'FontWeight','Bold','FontSize',14);%label the id of every task  ��������������������
end
