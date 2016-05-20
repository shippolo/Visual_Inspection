%% Created by Micah Lucas for educational purposes, 2016.
%  Software package for UBICOMP spring 2016.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global my_debug load_participant_responses use_GUI conds sub_layout resolution...
    auto_save figure_save_path p_ID pupil_means y_lims z_pad sr

% %% temp globals for debugging
% global means_bar_format std_bar_format





%% if false, don't reload data files if the 'participant' variable already exists
reload_participants=false; % I don't know why you would ever want this to be true...




auto_save=false;%true;% 
%% matlab sucks at save figures at resulutions higher than 1200 x 800 so
%  the vector below lets you set it to whatever you want. The first two
%  values have to be zero and the last two represent the resolution devided
%  by 100. so to get 1920 x 1080 resolution set it to [0,0,19.2,10.8] If
%  you want 4k resolution then multiply that entire vector by 4.
resolution=[0 0 19.2 10.8]*3;

figure_save_path='UBICOMP'; % figures get saved in '___\My Documents\Matlab\figure_save_path\

my_debug=false; % true = Pre-load settings. false > matlab asks you to enter everything 
%% debug values
if (my_debug)
    %% You MUST set ALL these values if my_debug=true 
	y_lims=[2.5,5]; %y axis limits 
    sub_layout=[3,6];
    data_col=4;
    
    plot_type=3;
    plot_by=1;
    
    %% only needed if you're using FFT
    % z_pad adds zeros to the end of each trial so the total trial length = z_pad
    % you need this so when you do fft all the trials are the same length
    z_pad=4000; 
    sr=120; % sample rate of the data
end

resample_data=false; % not implemented yet 5/19/2016




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% make sure the save folder exists
if (auto_save)
    if (~exist(figure_save_path,'dir')) 
        mkdir(figure_save_path)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check if data needs to be loaded
if((exist('participant','var')==0)||(reload_participants==true))
    UBICOMP_load_eye_data % load eye tracking data from files
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get condition variables from participant 1
%  to use these conditions:
%  cond.(conditions{i}){j}
%  this gets you the j'th condition for condition i.
conds=cc_assign(p_ID{1});






%% plots
%% set subplot size
if(~my_debug)
    sub_layout=input('Enter subplot layout (ex:[3,6]) : ');
    %% get plot options
    [pt_str, pb_str]=plot_eye_data;
    
    plot_type=input(sprintf('%s\n  : ',pt_str));
    plot_by=input(sprintf('%s\n  : ',pb_str));

    
    %% select column
    data_col=input('What column number would youn like to plot: ');
end



plot_eye_data(plot_type,plot_by,data_col,sub_layout);
%% Done!







%% Not working yet
% if (resample_data)
%     new_freq=input('Desired sample rate: ');
%     try
%         new_data=resample(new_freq);
%     catch ME
%     disp('failed to resample')
%     disp(ME.message)
%     end
% end




