function DAG = DAGgenerateFuc(Spec,NumPro,NumLayer,WcrtBound)

wcet_array = [];
WcrtLow=WcrtBound(1); % ��Ӧʱ��������
WcrtHigh=WcrtBound(2);
WcetLow=10; % ִ��ʱ��������
WcetHigh=100;
j=1; % ������ʵ������Ĳ���
g=2;

if(Spec==0) % ��Ϊ��˹ģ�͵ķ�Ӧʱ��������
    TaskNum=(NumLayer*NumLayer+NumLayer-2)/2; % �����������
    DAG_Matrix=zeros(TaskNum,TaskNum)-1; % ��Ӧʱ������ʼ��
    
    for i=1:NumLayer-1
        for k=j+1:j+NumLayer-i
            DAG_Matrix(j,k)=randi([WcrtLow,WcrtHigh],1);
        end
        j=j+1+NumLayer-i;
    end

    for i=1:NumLayer-2
        for k=1:NumLayer-i
            DAG_Matrix(g,g+NumLayer-i)=randi([WcrtLow,WcrtHigh],1);
            g=g+1;
        end
        g=g+1;
    end

elseif(Spec==1) % ��ΪFFTģ�͵ķ�Ӧʱ��������
    TaskNum=(2*NumLayer-1)+(NumLayer*log2(NumLayer)); % �����������
    DAG_Matrix=zeros(TaskNum,TaskNum)-1; % ��Ӧʱ������ʼ��
    
    for i = 0:1:log2(NumLayer)-1 % ��������ĸ�
        for j = 1:2^i
            DAG_Matrix(2^i+j-1, 2*(2^i+j-1)) = randi([WcrtLow,WcrtHigh],1);
            DAG_Matrix(2^i+j-1, 2*(2^i+j-1)+1) = randi([WcrtLow,WcrtHigh],1);
        end
    end
    
    for level = 1:log2(NumLayer) % �������������
        StartNum = NumLayer*level;
        k=0;
        for i = 0:NumLayer-1 % ������ֱ��
            DAG_Matrix(StartNum + i, StartNum + i + NumLayer) = randi([WcrtLow,WcrtHigh],1);
        end
        
        for i = 1:NumLayer/(2^level) % ����б�ŵ�
            for j=1:2^(level-1)
                DAG_Matrix(StartNum + k, StartNum + k + NumLayer + 2^(level-1)) = randi([WcrtLow,WcrtHigh],1);
                DAG_Matrix(StartNum + k + 2^(level-1), StartNum + k + NumLayer) = randi([WcrtLow,WcrtHigh],1);
                k=k+1;
            end
            k=k+2^(level-1);
        end
    end
end

DAG = FunctionClass;
DAG.E=DAG_Matrix; % ��Ӧʱ��
for i=1:NumPro
    wcet_array_for_one = randi([WcetLow,WcetHigh],1,TaskNum); % �������ʱ�����
    wcet_array = [wcet_array;wcet_array_for_one,i];
end
DAG.Wcet = wcet_array; % ִ��ʱ��


