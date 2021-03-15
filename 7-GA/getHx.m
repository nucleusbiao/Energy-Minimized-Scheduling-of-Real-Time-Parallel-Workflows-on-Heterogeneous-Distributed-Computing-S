function out=getHx(in)

%获取前置最多的出现次数
temp=tabulate(in(:));
if temp(1,1)~=0
    out=zeros(size(in,1),temp(1,2));
else
    out=zeros(size(in,1),temp(2,2));
end
index=ones(1,size(in,1));
for i=1:size(in,1)
    for j=1:size(in,2)
        if in(i,j)>0
            out(in(i,j),index(in(i,j)))=i;
            index(in(i,j))=index(in(i,j))+1;
        end
    end
end
