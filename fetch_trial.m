function [ trial ] = fetch_trial( pid, cond)
% function to fetch a specific trial given conditions and user.
% This function requires that the participant you want the trial for is
% already loaded into matlab function

%% Created by Micah Lucas for educational purposes, 2016.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% use example:
%trial=fetch_trial(p_ID{1},{conds.c_perms{4,:}});
% % or alternatevely
%cond={'lamps-2','1-back'};
%trial=fetch_trial(p_ID{1},cond);
%plot(trial{:,1},trial{:,4})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
global conditions participant


p=participant.(pid);
index=ones(length(p{:,1}),1);
trial_by_c=zeros(length(p{:,1}),length(conditions));
%% find trial data for eyes
for i=1:length(conditions)
    trial_by_c(:,i)=(strcmp(p.(conditions{i}),cond{i}));
    
    if isempty(trial_by_c(i))
        error('Trial condition "%s" was not found in "%s" column. Check that your spelling si correct.\n',cond{i}, conditions{i})
%         trial=[];
%         return
    end
    index=index & trial_by_c(:,i);
end
trial=participant.(pid)(index,:);
end

%% future additions:
%  might add condition codes but probably not
%  might add a spot for participant responses for n-backs
