function F = lowerBoundFuc(F)
% classdef FunctionClass
%    properties
%       wcet_tasks
%       DAG_matrix
%       priority_order
%       lowerbound
%    end
% end
%%
numECU = size(F.Wcet, 1);
numTask = size(F.E, 2);

EFTarray = [];
AFTarray = [];
availECU = zeros(numECU,1);
for i = 1:numTask
    EFTperTask = [];
    indexTask = F.priority_order(i);
    for j = 1:numECU
        if abs(indexTask-1) < 1e-6
            EFTperTask = [EFTperTask, F.Wcet(j,indexTask)];
        else
            ESTperECU = 0;
            predArray = pickUpPredFuc(F.E,indexTask);
            for indexPred = 1:size(predArray, 2)
                taskPred = predArray(indexPred);
                ESTperECU = max(ESTperECU, AFTarray(taskPred, 1) + abs(sign(AFTarray(taskPred, 2) - j))*F.E(taskPred, indexTask));
            end
            ESTperECU = max(availECU(j), ESTperECU);
            EFTperTask = [EFTperTask, ESTperECU+F.Wcet(j,indexTask)];
        end
    end
    EFTarray = [EFTarray; EFTperTask];
    [maxEFT, ecuOFmaxEFT] = min(EFTperTask);
    availECU(ecuOFmaxEFT) = maxEFT;
    % AFTarray = [AFTarray; availECU(ecuOFmaxEFT), ecuOFmaxEFT];
    AFTarray(indexTask,:) = [availECU(ecuOFmaxEFT), ecuOFmaxEFT];
end
F.lowerbound = min(EFTarray(end,:));