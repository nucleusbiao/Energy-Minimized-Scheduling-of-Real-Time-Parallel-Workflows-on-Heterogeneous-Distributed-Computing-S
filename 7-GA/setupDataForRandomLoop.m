function [ data ] = setupDataForRandomLoop( data, datact )
datact = datact';
datact(end,:)=[];
data.ct = datact;

datast = data.st;
for i = 1:size(datast,1)
    for j = 1:size(datast,2)
        if datast(i,j) > 0
            xharray(j,i) = i;
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
data.hx=getHx(data.xh); % ∫Û–Ú±Ì
end
