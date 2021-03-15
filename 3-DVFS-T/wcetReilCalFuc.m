function wcetLongest = wcetReilCalFuc(relReqForiTask, failureRate, wcetMin, d, energySpec, proIndex)

wcetMax = -log(relReqForiTask)/failureRate;
wcetMinConstant = wcetMin;
if wcetMax < wcetMin
    wcetLongest = wcetMin;
else
    while 1 
        wcetTemp = (wcetMin + wcetMax)/2;
        freq = wcetMinConstant/wcetTemp;
        relFreqRatio = failureRate*10^(d*(energySpec(proIndex,6)-freq)/(energySpec(proIndex,6)-energySpec(proIndex,5)));
        reliability = exp(-relFreqRatio*wcetTemp); 
        if abs(reliability - relReqForiTask) < 1e-5
            wcetLongest = wcetTemp;
            break
        elseif reliability > relReqForiTask
            wcetMin = wcetTemp;
        else
            wcetMax = wcetTemp;
        end
    end
end