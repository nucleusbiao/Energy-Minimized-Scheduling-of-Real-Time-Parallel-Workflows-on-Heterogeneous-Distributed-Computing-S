 function [AFTForTasks,ScheduleResult] = MSLFuc( DAG, relReq, failureRate)
%%
numProcessor = size(DAG.Wcet, 1); %���漸�е�����֮ǰ�ǳ�ʼ��
numTask = size(DAG.Wcet, 2)-1;
relPerTask=[];
AFTForTasksA = [];
stopFlagMSL = 0;
for i=1:numProcessor          
    eval(strcat('schedule.processor',num2str(i),' = [];'));
end

[relMax, relMaxPerTask] = relMaxFuc(DAG, failureRate);  % �����DVFS���ɿ��Ժ�ÿ����������ɿ���
if relMax < relReq
    AFTForTasks = 0; % ���һ����־λ
    % fprintf(1,'MSLFuc��15�������޷��ҵ�����ɿ��ԵĴ�����\n\n');
else
    for i = 1:numTask
        ScheduleLengthArray = [];
        indexTask = DAG.priority_order(i); % �������ȼ�����ѡ��Ҫִ�е�����
        relDenominator = 1; 
        
        % ����7��ͨ����ʽ21��������������ɿ���(MSL�㷨��8��)
        for j = 1:i-1
            relDenominator = relDenominator * relPerTask(j);
        end
        for j = i+1:numTask
            relDenominator = relDenominator * relMaxPerTask(j);
        end
        relReqForiTask = relReq/relDenominator;
        
        % �����ǽ�ÿ��������������ÿ��p����������ɿ��Ե�ȫ����������ѡ����֮��AFT��С���Ǹ�
        % WcetPerTaski = []; % ���ִ��ʱ�䣬��ѡ��Сִ��ʱ���
        indexPro = []; % ��Ŷ�Ӧ�Ĵ����������
        relPerTaski = []; % ��Ŷ�Ӧ�����������д������еĿɿ���
        FalseNumber = 0;
        predArray = pickUpPredFuc(DAG.E, indexTask); % ��ǵڼ������񵽵�i�������з�Ӧʱ���λ��
        for j = 1:numProcessor
            reliability = exp(-failureRate(j)*DAG.Wcet(j,indexTask)); % �����i�������ڴ�����j�ϵĿɿ��ԣ����ݹ�ʽ4��
            
            if reliability < relReqForiTask
                FalseNumber = FalseNumber + 1;
                relPerTaski = [relPerTaski,reliability];
                indexPro = [indexPro,j];
                ScheduleLengthArray = [ScheduleLengthArray, inf];
                if FalseNumber == numProcessor
                    AFTForTasks = 0; % ���һ����־λ
                    stopFlagMSL = 1;
                    continue
                    % fprintf(1,'MSLFuc��41�������޷��ҵ�����ɿ��ԵĴ�����\n\n');
                end
            else
                % ���ﱾ��Ҫ��t����p�ģ����ҷ��������if����AFTһ��ֵ
                relPerTaski = [relPerTaski,reliability];
                indexPro = [indexPro,j];
                % WcetPerTaski = [WcetPerTaski,DAG.Wcet(j,indexTask)];
                ESTForiTask = ESTForiTaskFuc( j, indexTask, predArray, schedule, DAG );
                ScheduleLengthArray = [ScheduleLengthArray, DAG.Wcet(j,indexTask) + ESTForiTask];
                
            end
            if j == numProcessor
                [a,b] = sort(ScheduleLengthArray);
                choicedPro = indexPro(b(1));
                relPerTask=[relPerTask,relPerTaski(b(1))]; % ��ʵ��ÿ������Ŀɿ��Դ�����
            end
        end
        
        if stopFlagMSL == 1
            break
        end
        
        % �������ù�ʽ22����AFT��������Ĵ�����
        % predArray = pickUpPredFuc(DAG.E, indexTask); % ��ǵڼ������񵽵�i�������з�Ӧʱ���λ��
        ESTForiTask = ESTForiTaskFuc( choicedPro, indexTask, predArray, schedule, DAG );
        AFTForiTask=ESTForiTask + DAG.Wcet(choicedPro,indexTask);
        eval(strcat('schedule.processor',num2str(choicedPro),'=[schedule.processor',num2str(choicedPro),';ESTForiTask,DAG.Wcet(choicedPro,indexTask),AFTForiTask,i,indexTask];'));
        % ������Ž���������
        % schedule.processorj�д洢���� ����ʼʱ�䣬����ʱ�䣬���ʱ�䣬�ڼ���ִ�е����񣬱�ִ������ı��

        AFTForTasksA = [AFTForTasksA,AFTForiTask]; % �����������ʱ��
        if i == numTask
            AFTForTasksA = sort(AFTForTasksA, 'descend');
            AFTForTasks = AFTForTasksA(1);
        end
    end
end
ScheduleResult = schedule;