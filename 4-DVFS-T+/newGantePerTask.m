function []=newGantePerTask(in, frequencyArray)

leng = 0.7;
num=length(fieldnames(in));%获取ECU个数
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
        
axis([0,max(dt)+1,0,num+0.5]);%x轴 y轴的范围
%set(gca,'xtick',0:cell((max(dt)+1)/10):max(dt)+1);%x轴的增长幅度
set(gca,'ytick',0:1:num+0.5) ;%y轴的增长幅度
xlabel('Time'),ylabel('Processor');%x轴 y轴的名称
% temp=['完工时间为',num2str(max(dt)),'的调度方案'];
% title(temp);%图形的标题

n_task_nb =task;%total tasks  //任务数目
%x轴 相应于绘图位置的起始坐标x
n_start_time=st;%start time of every task  //每一个工序的開始时间
%length 相应于每一个图形在x轴方向的长度
n_duration_time =dt-st;%duration time of every task  //每一个工序的持续时间
%y轴 相应于绘图位置的起始坐标y
n_bay_start=dn-1; %bay id of every task  ==机器号，即在哪一行画线
%工序号，能够依据工序号选择使用哪一种颜色
for i = 1:num
    rectangle('Position',[0,leng,max(dt),0.6],'LineWidth',1,'LineStyle','-','FaceColor','white');%draw every rectangle
    leng = leng+1;
end

rec=[0,0,0,0];%temp data space for every rectangle
color=['g','b','r','c','m','y'];
for i =1:n_task_nb
    rec(1) = n_start_time(i);%矩形的横坐标
    rec(2) = n_bay_start(i)+0.7;  %矩形的纵坐标
    rec(3) = n_duration_time(i);  %矩形的x轴方向的长度
    rec(4) = 0.6*frequencyArray(n_fid(i));
    %txt=sprintf('$T_{%d}$',n_fid(i));
    txt=sprintf('%d',n_fid(i));
    rectangle('Position',rec,'LineWidth',1,'LineStyle','-','FaceColor',color(6));%draw every rectangle
    %text(n_start_time(i)+0.2,(n_bay_start(i)+1),txt,'Color', 'black', 'Interpreter', 'latex','FontWeight','Bold','FontSize',14);%label the id of every task  ，字体的坐标和其他特性
    text(n_start_time(i)+0.2,(n_bay_start(i)+1),txt, 'FontWeight','Bold','FontSize',14);%label the id of every task  ，字体的坐标和其他特性
end
