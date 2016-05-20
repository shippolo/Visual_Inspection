function [ cond ] = cc_assign( pid )
%UNTITLED Summary of this function goes here
%   adds a condition code to particpant.p_ID, p_ID is a string eg: p03,p04
%   etc
global participant conditions
ps=participant; %for safeties sake
p=ps.(pid);
for i=1:length(conditions)
    cond_col=p.(conditions{i});
    pre_c{1}=cond_col{1};
    temp(1)=pre_c;
    index=2;
    for j =1:length(cond_col)
        cur_c=cond_col{j};
        if (~strcmp(cur_c,pre_c))
            
            temp{index}=cur_c;
            
            pre_c{index}=cur_c;
            index = index+1;   
        end
    end
    cond.(conditions{i})=sort(temp);
    temp_mat{i}=sort(temp);
    clearvars temp pre_c 
end

%% create a condition vector
OH_GOD_WHY='allcomb(';
for i=1:length(conditions)
    if(i==1)
        OH_GOD_WHY=sprintf('%scond.(conditions{%d})',OH_GOD_WHY,i);
    else
        OH_GOD_WHY=sprintf('%s, cond.(conditions{%d})',OH_GOD_WHY,i);
    end
end
OH_GOD_WHY=sprintf('%s);',OH_GOD_WHY);
cond.c_perms=eval(OH_GOD_WHY);
end

