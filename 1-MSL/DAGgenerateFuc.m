function DAG = DAGgenerateFuc(Spec,NumPro,NumLayer,WcrtBound)

wcet_array = [];
WcrtLow=WcrtBound(1); % 反应时间上下限
WcrtHigh=WcrtBound(2);
WcetLow=10; % 执行时间上下限
WcetHigh=100;
j=1; % 两个无实际意义的参数
g=2;

if(Spec==0) % 此为高斯模型的反应时间矩阵求解
    TaskNum=(NumLayer*NumLayer+NumLayer-2)/2; % 求出任务总数
    DAG_Matrix=zeros(TaskNum,TaskNum)-1; % 反应时间矩阵初始化
    
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

elseif(Spec==1) % 此为FFT模型的反应时间矩阵求解
    TaskNum=(2*NumLayer-1)+(NumLayer*log2(NumLayer)); % 求出任务总数
    DAG_Matrix=zeros(TaskNum,TaskNum)-1; % 反应时间矩阵初始化
    
    for i = 0:1:log2(NumLayer)-1 % 给了上面的盖
        for j = 1:2^i
            DAG_Matrix(2^i+j-1, 2*(2^i+j-1)) = randi([WcrtLow,WcrtHigh],1);
            DAG_Matrix(2^i+j-1, 2*(2^i+j-1)+1) = randi([WcrtLow,WcrtHigh],1);
        end
    end
    
    for level = 1:log2(NumLayer) % 给出下面的主体
        StartNum = NumLayer*level;
        k=0;
        for i = 0:NumLayer-1 % 给出垂直的
            DAG_Matrix(StartNum + i, StartNum + i + NumLayer) = randi([WcrtLow,WcrtHigh],1);
        end
        
        for i = 1:NumLayer/(2^level) % 给出斜着的
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
DAG.E=DAG_Matrix; % 反应时间
for i=1:NumPro
    wcet_array_for_one = randi([WcetLow,WcetHigh],1,TaskNum); % 产生完成时间矩阵
    wcet_array = [wcet_array;wcet_array_for_one,i];
end
DAG.Wcet = wcet_array; % 执行时间


