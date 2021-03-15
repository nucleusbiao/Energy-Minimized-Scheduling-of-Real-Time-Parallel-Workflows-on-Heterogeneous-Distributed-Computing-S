function Function = upwardRankFuc(Function, rankUvalueInitial)
% classdef FunctionClass
%    properties
%       wcet_tasks
%       DAG_matrix
%       priority_order
%    end
% end
rankUarray = [];
for i = 1:size(Function.E, 1)
    [rankUvalueI, rankUvalueInitial] = rankUvalueFuc(Function, i, rankUvalueInitial);
    if ~eq(min(rankUvalueInitial),0)
        break
    end
end
Function.upwardRank = rankUvalueInitial;
Function.upwardRankBackUp = rankUvalueInitial;
[B index] = sort(rankUvalueInitial, 'descend');
Function.priority_order = index;