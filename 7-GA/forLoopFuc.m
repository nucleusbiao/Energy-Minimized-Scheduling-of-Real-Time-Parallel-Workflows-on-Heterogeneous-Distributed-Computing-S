function [ SaveArray, SLtime] = forLoopFuc(info, data, relReq, failureRate, pop, popfmin)
tic
d=3;
scanValue = 0;
% pop=rand(info.np, info.n*3); % 40*30，40行为40个个体，每个个体都有多个任务。列均分为三部分，用来分配CPU、排优先级、设置任务频率(现在设置为0.8~1.0之间的随机数)
% popf = randi([9000,10000], info.np, info.n)/10000;
% pop(1:info.np, info.n*2+1:info.n*3) = popf;
temppNumFlag = 0;
fit=zeros(1,info.np);
able=zeros(1,info.np);%able=0表示为可行解，ab=1表示为不可行解
for i=1:info.np % 种群中的每个个体都进去运行
   [fit(i),able(i),~]=decode(pop(i,:),info,data,failureRate,relReq,d); % 是解码函数，返回适应度函数值（奖惩值）和是否为可行解(0为可行解)
end
poppc=zeros(size(pop));
poppm=zeros(size(pop));
fitnew=zeros(size(fit));
fitb=zeros(1,info.ng);
adv=zeros(info.np,info.n);
for I=1:info.ng
    [~,index]=sort(fit);
    fitb(I)=min(fit);
    popb=pop(index(1),:); % 受惩罚最小的个体取出并保存
    
    if 1 == size(find(fit<1e20),2) %当出现只有一个可行解的情况，就复制一份可行解，否则的话在cr中会陷入死循环
        if 1 == find(fit<1e20)
            pop(2,:) = pop(find(fit<1e20),:);
            fit(2) = fit(find(fit<1e20));
            able(2) = 0;
        else
            pop(1,:) = pop(find(fit<1e20),:);
            fit(1) = fit(find(fit<1e20));
            able(1) = 0;
        end
    end
    poppc=cr(pop,fit,info.pc); % 交叉
    poppm=mu(poppc,info.pm); % 变异
    for i=1:info.np
        [fitnew(i),able(i),adv(i,:)]=decode(poppm(i,:),info,data,failureRate,relReq,d);
    end
    for i=1:info.np % 频率大于0.9900的全部改为1
       for j=1:info.n
          if adv(i,j)==1
              poppm(i,info.n*2+j)=1;
          end
       end
    end
    %for i=1:info.np
    %    [fitnew(i),able(i),adv(i,:)]=decode(poppm(i,:),info,data);
    %end
    pop(index(end),:)=popb; % 用受惩罚最小的个体替代受惩罚最大的个体
    for i=1:info.np
       if fitnew(i)<fit(i)
          pop(i,:)=poppm(i,:);
          fit(i)=fitnew(i);
       end
    end
    tempp=length(find(able==0));
    scanValue = scanValue+1;
    if scanValue == 1000
        temp=['当前迭代次数为：',num2str(I),'，最佳适应度函数值为：',num2str(min(fit)),'，可行解个数为：',num2str(tempp)];
        disp(temp)
        scanValue = 0;
    end
    
    if (tempp>=30) && (min(fitnew)<1e20) % 如果长时间满足可靠性要求，则降低频率试试，逐步扩大频率的范围。避免刚开始完全找不到解的情况
        temppNumFlag = temppNumFlag + 1;
        if (temppNumFlag > 100)
            temppNumFlag = 0; % 把标志位清0
            popfmin = popfmin - 100;
            if popfmin < 0
                popfmin = 0;
            end
            popf = randi([popfmin,10000], info.np, info.n)/10000;
            pop(1:info.np, info.n*2+1:info.n*3) = popf;
            
            pop(1,:) = popb; %保留两份之前的最优解数据
            pop(2,:) = popb;
            for i=1:info.np % 种群中的每个个体都进去运行
                [fit(i),~,~]=decode(pop(i,:),info,data,failureRate,relReq,d); % 是解码函数，返回适应度函数值（奖惩值）和是否为可行解(0为可行解)
            end
        end
    end
end
toc
SLtime = toc;
sch=decode2(popb,info,data);

% 把调度结果信息保存起来
dataNeed = resInformation(popb,info,data,failureRate,relReq,d); % 调度时长、调度时长约束、可靠性、可靠性约束、任务所在处理器数组、任务频率数组、任务开始执行的时间数组

SaveArray = [sch.e, dataNeed]; % 能耗、
figure
gante(sch,info);
end