function Function = upwardRankFuc(Function, rankUvalueInitial)
% classdef FunctionClass
%    properties
%       wcet_tasks
%       DAG_matrix
%       priority_order
%    end
% end
rankUarray = [];
for i = size(Function.E, 1):-1:1
    rankUvalueI = rankUvalueFuc(Function, i, rankUvalueInitial);
    rankUvalueInitial(i) = rankUvalueI;
    rankUarray = [rankUvalueI, rankUarray];
end
Function.upwardRank = rankUarray;
Function.upwardRankBackUp = rankUarray;
[B, index] = sort(rankUarray, 'descend');
Function.priority_order = index;