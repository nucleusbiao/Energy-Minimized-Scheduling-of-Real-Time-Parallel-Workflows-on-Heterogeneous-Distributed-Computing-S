function [locationEcu, schedule] = tickOutChosenTask(schedule, iTask)
% �����ڸı�Ƶ�ʵ�����������
num=length(fieldnames(schedule));%��ȡECU����

for i=1:num
    temp=['ecu=schedule.processor',num2str(i),';'];
    eval(temp);
    for j = 1:size(ecu, 1)
        if eq(iTask, ecu(j,5))
            locationEcu = i;
            ecu = [ecu(1:j-1,:); ecu(j+1:end,:)];
            temp=['schedule.processor',num2str(i),'=ecu;'];
            eval(temp);
            break
        end
    end
end