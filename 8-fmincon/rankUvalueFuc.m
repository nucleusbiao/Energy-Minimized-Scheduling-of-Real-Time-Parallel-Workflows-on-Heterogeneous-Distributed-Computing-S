function rankUvalueI = rankUvalueFuc(Function, i, rankUvalueInitial)
% classdef FunctionClass
%    properties
%       wcet_tasks
%       DAG_matrix
%       priority_order
%    end
% end
succArray = pickUpSuccFuc(Function.E,i);
rankUvalueI = 0;
if size(succArray, 2) > 1e-6
    for step = 1:size(succArray, 2)
        indexSucc = succArray(step);
        rankUvalueI = max(rankUvalueI, Function.E(i, indexSucc)+rankUvalueInitial(indexSucc));
    end
end
rankUvalueI = ceil(mean(Function.Wcet(:,i))) + rankUvalueI; % 朝大的方向取整