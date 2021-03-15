function [ xh ] = xhCalculate( DAG )
% 根据DAG.E计算先序表
DAGE = DAG.E;
NumTask = size(DAG.E, 1);
xh = zeros(NumTask, NumTask);
for i = 1:NumTask
    n = 1;
    for j = 1:NumTask
        if DAGE(j,i) > 0
            xh(i,n) = j;
            n = n+1;
        end
    end
end
xh(:,all(xh==0,1)) = [];
end

