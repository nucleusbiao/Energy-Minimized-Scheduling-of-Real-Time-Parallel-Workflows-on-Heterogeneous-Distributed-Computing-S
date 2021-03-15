function relDenominator = relArrayMulFuc(relMaxPerTask, i)

relDenominator = 1;
for j = 1:size(relMaxPerTask, 2)
    relDenominator = relDenominator * relMaxPerTask(j);
end

relDenominator = relDenominator/relMaxPerTask(i);