function [relMax, relMaxPerTask] = relMaxFuc(DAG, failureRate)

wcetArray = DAG.Wcet;
relMax = 1;
relMaxPerTask = [];
for i = 1:(size(wcetArray, 2)-1)
    relTempMax = 0;
    indexTask = DAG.priority_order(i);
    for j = 1:size(wcetArray, 1)
        relTempMax = max(relTempMax, exp(-failureRate(j)*wcetArray(j,indexTask)));
    end
    relMaxPerTask = [relMaxPerTask, relTempMax];
    relMax = relMax * relTempMax;
end