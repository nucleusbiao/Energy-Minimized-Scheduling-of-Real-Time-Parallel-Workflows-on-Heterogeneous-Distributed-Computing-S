function popout=mu(pop,pm)

popout=pop;
[ps,l]=size(pop);
for i=1:ps
    temp=rand(1,1);
    if temp<pm
        temp=randperm(l);
        cw1=temp(1);
        cw2=temp(2);
        popout(i,cw1)=rand(1,1);
        popout(i,cw2)=rand(1,1);
    end
end