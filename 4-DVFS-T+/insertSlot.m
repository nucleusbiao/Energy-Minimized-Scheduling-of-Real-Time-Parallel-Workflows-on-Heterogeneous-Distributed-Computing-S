function ecuSchedule = insertSlot(ecuSchedule, slot, iTask,iCountTask)
sceduleL=slot(2)-slot(1);
slot1=[slot(1),sceduleL,slot(2)];
if eq(size(ecuSchedule,1), 0)
    ecuSchedule = [slot1, iCountTask, iTask];
else
    if eq(size(ecuSchedule,1), 1)
        if ecuSchedule(1,1) >= slot1(3)
            ecuSchedule = [slot1, iCountTask, iTask; ecuSchedule];
        else
            ecuSchedule = [ecuSchedule; slot1, iCountTask, iTask];
        end
    else
        if ecuSchedule(1,1) >= slot1(3)
            ecuSchedule = [slot1, iCountTask, iTask; ecuSchedule];
        else
            for j = 2:size(ecuSchedule,1)
                if ecuSchedule(j,1) >= slot1(3) && ecuSchedule(j-1,3) <= slot1(1)
                    ecuSchedule = [ecuSchedule(1:j-1,:); slot1, iCountTask, iTask; ecuSchedule(j:end,:)];
                    break
                end
                if eq(j, size(ecuSchedule,1))
                    ecuSchedule = [ecuSchedule; slot1, iCountTask, iTask];
                end
            end
        end
    end
end