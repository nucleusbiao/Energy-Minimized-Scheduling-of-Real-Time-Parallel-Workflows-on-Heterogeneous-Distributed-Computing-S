function ESTForiTask = ESTForiTaskFuc( processor, taskIndex, predArray, schedule, DAG )
% ���ڼ�����������翪ʼʱ��
m=0; % ���ڱ��֮ǰ�м������������������ϵ
scheduleBF=[];
eval(strcat('scheduleBF = schedule.processor',num2str(processor),';'));
mm = isempty(scheduleBF);
availPro = DAG.arrivalTime;
if mm == 0
    availPro = scheduleBF(end,3); % ����ô������Ŀ���ʱ��
end
AFTForPredTask = 0;
for i=1:size(predArray,2) % ���м���֮ǰ��ص�����
    if predArray(i)>0
        m=m+1;
    end
end
InsertFlag = 0;

if m==0 % û��ǰ������ʱ������һ������ʱ
    if DAG.priority_order(1) == taskIndex
        ESTForiTask = DAG.arrivalTime; % Ϊ��һ��ִ�е�����ʱ
    else % ��Ȼû��ǰ�����񣬵��˴�����֮ǰ���������ʱ������Ƕ�����񣡣�
        if size(scheduleBF, 1) == 0
            ESTForiTask = DAG.arrivalTime;
        else
            ESTForiTask = max(scheduleBF(:,3));
        end
        if size(scheduleBF, 1) >= 1
            FinishArray = [];
            BiginArray = [];
            for l=1:size(scheduleBF,1) % �Ѹô���������������Ŀ�ʼʱ��ͽ���ʱ�������
                FinishArray = [FinishArray, scheduleBF(l,3)];
                BiginArray = [BiginArray, scheduleBF(l,1)];
            end
            FinishArray = sort(FinishArray);
            BiginArray = sort(BiginArray);
            for q = 1:size(scheduleBF, 1) % ����Ƕ������
                if q == 1 % ����Ƕ�������������һ������֮ǰʱ
                    if (BiginArray(q)-DAG.arrivalTime) > DAG.Wcet(processor,taskIndex)
                        ESTForiTask = DAG.arrivalTime;
                        break
                    end
                elseif (BiginArray(q)-FinishArray(q-1)) > DAG.Wcet(processor,taskIndex) % ����Ƕ������������ķǵ�һ������֮ǰʱ
                    ESTForiTask = FinishArray(q-1);
                    break
                end
            end
        end
    end 
else % ��ǰ������ʱ
    PredNumflag = 0;
    ESTForiTaskArray = [];
    for i=1:size(DAG.Wcet,1)
        eval(strcat('n = schedule.processor',num2str(i),';'));
        if isempty(n)
            continue
        else
            ProArray = [];
            for j = 1:size(n,1) % �Ѵ������е�������Ŵ�����
                ProArray = [ProArray, n(j,5)];
            end
            intersectionArray = intersect(predArray, ProArray); % �ҳ��ô�������ǰ������
            if isempty(intersectionArray) % �ô���������ǰ������ʱ
                continue
            else % �ô���������ǰ������ʱ
                for k = 1:size(intersectionArray,2)
                    for g = 1:size(n,1) % ѡ��ǰ���������
                        if n(g, 5) == intersectionArray(k)
                            break
                        end
                    end
                    if i == processor
                        ESTForiTaskArray = [ESTForiTaskArray, n(g, 3)];
                        PredNumflag = PredNumflag+1;
                        % intersectionArray(k) = []; % �����ҵ���ǰ������ȥ������ûд��
                    else
                        ESTForiTaskArray = [ESTForiTaskArray, n(g, 3) + DAG.E(intersectionArray(k),taskIndex)];
                        PredNumflag = PredNumflag+1;
                        % intersectionArray(k) = []; % �����ҵ���ǰ������ȥ������ûд��
                    end
                end
                if PredNumflag == m % ǰ�������Ѿ���ȫ�����
                    ESTDescendArray = sort(ESTForiTaskArray, 'descend');
                    FinishArray = [];
                    BiginArray = [];
                    for l=1:size(scheduleBF,1) % �Ѹô���������������Ŀ�ʼʱ��ͽ���ʱ�����������������Ƕ��
                        FinishArray = [FinishArray, scheduleBF(l,3)];
                        BiginArray = [BiginArray, scheduleBF(l,1)];
                    end
                    FinishArray = sort(FinishArray);
                    BiginArray = sort(BiginArray);
                    if isempty(scheduleBF)
                        ESTForiTask = ESTDescendArray(1);
                        break
                    else
                        for q = 1:size(scheduleBF,1) % ����Ƕ������
                            if q == 1 % ����Ƕ�������������һ������֮ǰʱ
                                if (BiginArray(q)-ESTDescendArray(1)) > DAG.Wcet(processor,taskIndex)
                                    ESTForiTask = ESTDescendArray(1);
                                    InsertFlag = 1;
                                    break
                                end
                            elseif ((BiginArray(q)-FinishArray(q-1))>DAG.Wcet(processor,taskIndex)) && ((BiginArray(q)-ESTDescendArray(1))>DAG.Wcet(processor,taskIndex)) % ����Ƕ������������ķǵ�һ������֮ǰʱ
                                if FinishArray(q-1) > ESTDescendArray(1)
                                    ESTForiTask = FinishArray(q-1);
                                    InsertFlag = 1;
                                    break
                                else
                                    ESTForiTask = ESTDescendArray(1);
                                    InsertFlag = 1;
                                    break
                                end 
                            end
                        end
                        if InsertFlag == 0 % Ƕ��ʧ�ܵ����
                            ESTForiTask = max(ESTDescendArray(1), FinishArray(end));
                        end
                        break
                    end
                end
                
            end
        end
    end
end
% elseif m==1 % ǰ���������ֻ��һ��ʱ
%     predPro = 0;
%     for i=1:size(DAG.Wcet,1) % �ҳ�֮ǰ����������ڵĴ���������ȡ��ǰ��������ʱ��
%         
%         eval(strcat('n = schedule.processor',num2str(i),';'));
%         if isempty(n)
%             continue
%         else
%             eval(strcat('n = schedule.processor',num2str(i),'(:,5);'));
%             for j=1:size(n,1)
%                 if n(j) == predArray
%                     eval(strcat('AFTForPredTask = schedule.processor',num2str(i),'(j,3);')); % ǰ��������ʱ��
%                     eval(strcat('predPro=i;')); % ǰ�������ڴ�����
%                 end
%             end
%         end
%     end
%     if predPro ~= 0
%         if processor == predPro % ��ǰ������ͬһ������ʱ
%             ESTForiTask = max(availPro,AFTForPredTask);
%         else % ��ǰ�����ڲ�ͬ������ʱ
%             ESTForiTask = max(availPro,AFTForPredTask + DAG.E(predArray,task));
%         end
%     end
% else % ǰ���������������ʱ
%     predPro1 = 0;
%     predPro2 = 0;
%     for i=1:size(DAG.Wcet,1) % �ҳ�֮ǰ����������ڵĴ���������ȡ��ǰ��������ʱ��
%         eval(strcat('n = schedule.processor',num2str(i),';'));
%         if isempty(n)
%             continue
%         else
%             eval(strcat('n = schedule.processor',num2str(i),'(:,5);'));
%             for j=1:size(n,1)
%                 if n(j) == predArray(1)
%                     eval(strcat('AFTForPredTask1 = schedule.processor',num2str(i),'(j,3);')); % ǰ��������ʱ��
%                     eval(strcat('predPro1=i;')); % ǰ�������ڴ�����
%                 end
%                 if n(j) == predArray(2)
%                     eval(strcat('AFTForPredTask2 = schedule.processor',num2str(i),'(j,3);')); % ǰ��������ʱ��
%                     eval(strcat('predPro2=i;')); % ǰ�������ڴ�����
%                 end
%             end
%         end
%     end
%     
%  %   if predPro1 ~= 0
%         if predPro1 == predPro2 % ������ǰ������ͬһ������ʱ
%             if processor == predPro1 % ��ǰ������ͬһ������ʱ
%                 ESTForiTask = max(AFTForPredTask1,AFTForPredTask2);
%                 ESTForiTask = max(availPro,ESTForiTask);
%             else % ��ǰ�����ڲ�ͬ������ʱ
%                 if AFTForPredTask1 > AFTForPredTask2
%                     ESTForiTask = max(availPro,AFTForPredTask1 + DAG.E(predArray(1),task));
%                 else
%                     ESTForiTask = max(availPro,AFTForPredTask2 + DAG.E(predArray(2),task));
%                 end
%             end
%             
%         else % ������ǰ������ͬһ������ʱ
%             if processor == predPro1 % ��ĳ��ǰ������ͬһ������ʱ
%                 if (AFTForPredTask2 + DAG.E(predArray(2),task)) > AFTForPredTask1
%                     ESTForiTask = max(availPro,AFTForPredTask2 + DAG.E(predArray(2),task));
%                 else
%                     ESTForiTask = max(availPro,AFTForPredTask1);
%                 end
%             elseif processor == predPro2
%                 if (AFTForPredTask1 + DAG.E(predArray(1),task)) > AFTForPredTask2
%                     ESTForiTask = max(availPro,AFTForPredTask1 + DAG.E(predArray(1),task));
%                 else
%                     ESTForiTask = max(availPro,AFTForPredTask2);
%                 end
%             else % ��ǰ���񶼲���ͬһ������ʱ
%                 ESTForiTask = max((AFTForPredTask1 + DAG.E(predArray(1),task)), (AFTForPredTask2 + DAG.E(predArray(2),task)));
%                 ESTForiTask = max(availPro,ESTForiTask);
%             end
%         end
%  %   end
% end