function [ SaveArray, SLtime] = forLoopFuc(info, data, relReq, failureRate, pop, popfmin)
tic
d=3;
scanValue = 0;
% pop=rand(info.np, info.n*3); % 40*30��40��Ϊ40�����壬ÿ�����嶼�ж�������о���Ϊ�����֣���������CPU�������ȼ�����������Ƶ��(��������Ϊ0.8~1.0֮��������)
% popf = randi([9000,10000], info.np, info.n)/10000;
% pop(1:info.np, info.n*2+1:info.n*3) = popf;
temppNumFlag = 0;
fit=zeros(1,info.np);
able=zeros(1,info.np);%able=0��ʾΪ���н⣬ab=1��ʾΪ�����н�
for i=1:info.np % ��Ⱥ�е�ÿ�����嶼��ȥ����
   [fit(i),able(i),~]=decode(pop(i,:),info,data,failureRate,relReq,d); % �ǽ��뺯����������Ӧ�Ⱥ���ֵ������ֵ�����Ƿ�Ϊ���н�(0Ϊ���н�)
end
poppc=zeros(size(pop));
poppm=zeros(size(pop));
fitnew=zeros(size(fit));
fitb=zeros(1,info.ng);
adv=zeros(info.np,info.n);
for I=1:info.ng
    [~,index]=sort(fit);
    fitb(I)=min(fit);
    popb=pop(index(1),:); % �ܳͷ���С�ĸ���ȡ��������
    
    if 1 == size(find(fit<1e20),2) %������ֻ��һ�����н��������͸���һ�ݿ��н⣬����Ļ���cr�л�������ѭ��
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
    poppc=cr(pop,fit,info.pc); % ����
    poppm=mu(poppc,info.pm); % ����
    for i=1:info.np
        [fitnew(i),able(i),adv(i,:)]=decode(poppm(i,:),info,data,failureRate,relReq,d);
    end
    for i=1:info.np % Ƶ�ʴ���0.9900��ȫ����Ϊ1
       for j=1:info.n
          if adv(i,j)==1
              poppm(i,info.n*2+j)=1;
          end
       end
    end
    %for i=1:info.np
    %    [fitnew(i),able(i),adv(i,:)]=decode(poppm(i,:),info,data);
    %end
    pop(index(end),:)=popb; % ���ܳͷ���С�ĸ�������ܳͷ����ĸ���
    for i=1:info.np
       if fitnew(i)<fit(i)
          pop(i,:)=poppm(i,:);
          fit(i)=fitnew(i);
       end
    end
    tempp=length(find(able==0));
    scanValue = scanValue+1;
    if scanValue == 1000
        temp=['��ǰ��������Ϊ��',num2str(I),'�������Ӧ�Ⱥ���ֵΪ��',num2str(min(fit)),'�����н����Ϊ��',num2str(tempp)];
        disp(temp)
        scanValue = 0;
    end
    
    if (tempp>=30) && (min(fitnew)<1e20) % �����ʱ������ɿ���Ҫ���򽵵�Ƶ�����ԣ�������Ƶ�ʵķ�Χ������տ�ʼ��ȫ�Ҳ���������
        temppNumFlag = temppNumFlag + 1;
        if (temppNumFlag > 100)
            temppNumFlag = 0; % �ѱ�־λ��0
            popfmin = popfmin - 100;
            if popfmin < 0
                popfmin = 0;
            end
            popf = randi([popfmin,10000], info.np, info.n)/10000;
            pop(1:info.np, info.n*2+1:info.n*3) = popf;
            
            pop(1,:) = popb; %��������֮ǰ�����Ž�����
            pop(2,:) = popb;
            for i=1:info.np % ��Ⱥ�е�ÿ�����嶼��ȥ����
                [fit(i),~,~]=decode(pop(i,:),info,data,failureRate,relReq,d); % �ǽ��뺯����������Ӧ�Ⱥ���ֵ������ֵ�����Ƿ�Ϊ���н�(0Ϊ���н�)
            end
        end
    end
end
toc
SLtime = toc;
sch=decode2(popb,info,data);

% �ѵ��Ƚ����Ϣ��������
dataNeed = resInformation(popb,info,data,failureRate,relReq,d); % ����ʱ��������ʱ��Լ�����ɿ��ԡ��ɿ���Լ�����������ڴ��������顢����Ƶ�����顢����ʼִ�е�ʱ������

SaveArray = [sch.e, dataNeed]; % �ܺġ�
figure
gante(sch,info);
end