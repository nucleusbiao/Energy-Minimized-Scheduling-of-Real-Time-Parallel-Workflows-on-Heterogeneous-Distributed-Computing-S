function [rankUvalueI, rankUvalueInitial] = rankUvalueFuc(Function, i, rankUvalueInitial)
% classdef FunctionClass
%    properties
%       wcet_tasks
%       DAG_matrix
%       priority_order
%    end
% end

if ~eq(rankUvalueInitial(i), 0)
    rankUvalueI = rankUvalueInitial(i);
else
    succArray = pickUpSuccFuc(Function.E,i);
    rankUvalueI = 0;
    if size(succArray, 2) > 1e-6
        for step = 1:size(succArray, 2)
            indexSucc = succArray(step);
            if eq(rankUvalueInitial(indexSucc), 0)
                succArray2 = pickUpSuccFuc(Function.E,indexSucc);
                if size(succArray2, 2) > 1e-6
                    [rankUvalueIndexSucc, rankUvalueInitial] = rankUvalueFuc(Function, indexSucc, rankUvalueInitial);
                    rankUvalueInitial(indexSucc) = rankUvalueIndexSucc;
                else
                    rankUvalueInitial(indexSucc) = ceil(mean(Function.Wcet(:,indexSucc)));
                end
            end
            rankUvalueI = max(rankUvalueI, Function.E(i, indexSucc)+rankUvalueInitial(indexSucc));
        end
    end
    rankUvalueI = ceil(mean(Function.Wcet(:,i))) + rankUvalueI;
    rankUvalueInitial(i) = rankUvalueI;
end