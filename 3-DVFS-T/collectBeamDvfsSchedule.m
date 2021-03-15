function [scheduleBeam, relMaxPerTaskBeam, frequencyOut] = collectBeamDvfsSchedule(scheduleBeamTemp, relMaxPerTaskBeamTemp, beamSize,  energySpec, frequencyArray, indexTask)

energyTotalSet = [];
scheduleCellSetIn = scheduleBeamTemp;
relMaxPerTaskCellSetIn = relMaxPerTaskBeamTemp;

for i = 1:size(scheduleCellSetIn, 2)
    if ~isempty(scheduleCellSetIn{i})
        makeSpanMax = 0;
        schedule = scheduleCellSetIn{i};
        energyTotal = energyCalDvfsFuc(schedule, energySpec, frequencyArray, indexTask);
        energyTotalSet(i) = energyTotal;
    else
        energyTotalSet(i) = 1e30;
    end
end

[result, indexS] = sort(energyTotalSet);

for i = 1:beamSize
    scheduleBeam{i} = scheduleCellSetIn{indexS(i)};
    relMaxPerTaskBeam{i} = relMaxPerTaskCellSetIn{indexS(i)};
    frequencyOut = frequencyArray(indexS(i));
end