function gante(sch,info)

dt=sch.dt;
st=sch.st;
dn=sch.dn;
mt=sch.mt;
e=sch.e;

figure(1)
axis([0,max(dt)+1,0,info.m+0.5]);%x轴 y轴的范围
%set(gca,'xtick',0:cell((max(dt)+1)/10):max(dt)+1);%x轴的增长幅度
set(gca,'ytick',0:1:info.m+0.5) ;%y轴的增长幅度
xlabel('时间'),ylabel('ECU号');%x轴 y轴的名称
temp=['makespan为',num2str(max(mt)),'的调度方案，能量消耗为：',num2str(e)];
title(temp);%图形的标题

n_task_nb =sum(info.n);%total tasks  //任务数目
%x轴 相应于绘图位置的起始坐标x
n_start_time=st;%start time of every task  //每一个工序的開始时间
%length 相应于每一个图形在x轴方向的长度
n_duration_time =dt-st;%duration time of every task  //每一个工序的持续时间
%y轴 相应于绘图位置的起始坐标y
n_bay_start=dn-1; %bay id of every task  ==工序数目，即在哪一行画线
%工序号，能够依据工序号选择使用哪一种颜色
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
        error('数据错误');
    end
end
rec=[0,0,0,0];%temp data space for every rectangle  
%color=['r','g','b','c','m','y'];
for i =1:n_task_nb  
    rec(1) = n_start_time(i);%矩形的横坐标
    rec(2) = n_bay_start(i)+0.7;  %矩形的纵坐标
    rec(3) = n_duration_time(i);  %矩形的x轴方向的长度
    rec(4) = 0.6;
    txt=sprintf('%d,%d',n_fid(i),lx(i));
    rectangle('Position',rec,'LineWidth',0.5,'LineStyle','-','FaceColor','w');%draw every rectangle  
    text(n_start_time(i)+0.2,(n_bay_start(i)+1),txt,'FontWeight','Bold','FontSize',14);%label the id of every task  ，字体的坐标和其他特性
end  