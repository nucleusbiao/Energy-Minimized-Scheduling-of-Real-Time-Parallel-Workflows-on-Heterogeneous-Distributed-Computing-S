function [relMax, relMaxPerTask] = relMaxFuc(DAG, failureRate)
numTask = size(DAG.E, 2);
numPro = size(DAG.Wcet, 1);

wcetArray = DAG.Wcet;
relMax = 1;
relMaxPerTask = [];
for i = 1:numTask
    relTempMax = 0;
    indexTask = DAG.priority_order(i);
    for j = 1:numPro
        relTempMax = max(relTempMax, exp(-failureRate(j)*wcetArray(j,indexTask)));
    end
    relMaxPerTask = [relMaxPerTask, relTempMax];
    relMax = relMax * relTempMax;
end