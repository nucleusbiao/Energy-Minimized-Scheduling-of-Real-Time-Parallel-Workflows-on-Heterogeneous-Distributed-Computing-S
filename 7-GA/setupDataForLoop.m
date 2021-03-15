function [ data ] = setupDataForLoop( data, datact, Spec, NumLayer )
j=1; % ������ʵ������Ĳ���
g=2;
datact = datact';
datact(end,:)=[];
data.ct = datact;
if Spec==0 % ���if��������ǰ���
    for i=1:NumLayer-1
        for k=j+1:j+NumLayer-i
            xharray(k,j)=j;
        end
        j=j+1+NumLayer-i;
    end
    for i=1:NumLayer-2
        for k=1:NumLayer-i
            xharray(g+NumLayer-i,g)=g;
            g=g+1;
        end
        g=g+1;
    end
elseif Spec==1
    for i = 0:1:log2(NumLayer)-1 % ��������ĸ�
        for j = 1:2^i
            xharray(2*(2^i+j-1), 2^i+j-1) = 2^i+j-1;
            xharray(2*(2^i+j-1)+1,2^i+j-1 ) = 2^i+j-1;
        end
    end
    for level = 1:log2(NumLayer) % �������������
        StartNum = NumLayer*level;
        k=0;
        for i = 0:NumLayer-1 % ������ֱ��
            xharray(StartNum + i + NumLayer, StartNum + i) = StartNum + i;
        end
        
        for i = 1:NumLayer/(2^level) % ����б�ŵ�
            for j=1:2^(level-1)
                xharray(StartNum + k + NumLayer + 2^(level-1), StartNum + k) = StartNum + k;
                xharray(StartNum + k + NumLayer, StartNum + k + 2^(level-1)) = StartNum + k + 2^(level-1);
                k=k+1;
            end
            k=k+2^(level-1);
        end
    end
end
[imax,jmax]=size(xharray);
for i=1:imax
    m=1;
    for j=1:jmax
        if xharray(i,j)~=0
            data.xh(i,m)=j;
            m=m+1;
        end
    end
end
data.hx=getHx(data.xh); % �����
end

