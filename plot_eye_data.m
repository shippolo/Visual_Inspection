function [pt_str, pb_str] = plot_eye_data(plot_type, plot_by, data_col, sub_layout)
global my_debug participant p_ID conditions conds auto_save resolution ...
    figure_save_path pupil_means y_lims z_pad sr

% temp globals for debugging
global means_bar_format std_bar_format

if(nargin==0)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% list all availible plots here
    p_t(1)={'(1) Time domain plot'};
    p_t(2)={'(2) Frequency domain plot(FFT)'};
    p_t(3)={'(3) Means and standard deviations'};
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% list all plot_by optioins
    p_b(1)={'(1) plot by participants'};
    p_b(2)={'(2) Plot by trial'};
    % p_b(3)={'(3) Average all participants'}; getting a lot of bugs so i removed it. will include it later
    % p_b(4)={'(4) Average all selected condition'};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    
    pt_str='What type of plot would you like:\n';
    pb_str='What type of plots do you want on each figure:\n';
    % combine all the text above into a single string
    for i=1:length(p_t)
        pt_str=strcat(pt_str,p_t{i},'\n');
    end
    for i=1:length(p_b)
        pb_str=strcat(pb_str,p_b{i},'\n');
    end
    
    return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sample code example: time domain plot by participants
%% use as reference if you want to add your own plots
% i_end=length(p_ID);
% j_end=length(conds.c_perms);
% 
% for i=1:i_end % step through each participant
%     temp_fig=figure; % create a figure for participant i
%     
%     for j=1:j_end % step through all the trial conditions
%         
%         tr_args={conds.c_perms{j,:}}; % load the trial conditions for the j'th plot
%         
%         trial=fetch_trial(p_ID{i},tr_args); % load only the data for the given participant and trial conditions
%         
%         x_dat=trial{:,1} - trial{1,1}; % make the time axis start at 0
%         y_dat=trial{:,data_col}; %data to get plotted
%         
%         
%         subplot(sub_layout(1), sub_layout(2), j) % select the subplot to plot to
%         plot(x_dat,y_dat)
%         
% 
%         str=strjoin(tr_args); % subplot title
%         title(str)
%         
%         xlab='Time'; % label subplot axis
%         xlabel(xlab)
%         ylabel(trial.Properties.VariableNames(data_col))
%         
%         xlim([min(x_dat), max(x_dat)]) % set axis limits
%         ylim(y_lims)
%         
%         clearvars trial str x_dat y_dat
%     end
% 
%     
%     title_str=sprintf('Participant %s %s',p_ID{i},char(participant.(p_ID{i}).Properties.VariableNames(data_col)));
%     if (auto_save)
%         fID=strcat(figure_save_path,'\', str, '.jpg'); % file name for the saved figure
%         set(temp_fig,'PaperUnits','inches','PaperPosition',resolution); % set the figure resolution
%         print('-djpeg','-r100',fID) % save figure
%         close(temp_fig)
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plots
if (((plot_type==1)||(plot_type==2)||(plot_type==3))&&((plot_by==1)||(plot_by==2))) % plot data in time or frequency
    if (~my_debug)
        y_lims=input('Enter y-axis limits: ');
    end
    if (plot_by==1)%  plot by participants
        i_end=length(p_ID);
        j_end=length(conds.c_perms);
        
        
        f_eval(1)={'tr_args={conds.c_perms{j,:}};'};
        f_eval(2)={'trial=fetch_trial(p_ID{i},tr_args);'};
        %         f_eval(3)={'title_str=''sprintf(''Participant %s %s'',p_ID{i},char(participant.(p_ID{i}).Properties.VariableNames(data_col)));'';'};% title of the figure
        
        f_eval(3)={'str=strjoin(tr_args);'}; % title of the plot
        
        title_str='sprintf(''Participant %s %s'',p_ID{i},char(participant.(p_ID{i}).Properties.VariableNames(data_col)));';
        
    elseif (plot_by==2)% Plot by trial
        i_end=length(conds.c_perms);
        j_end=length(p_ID);
        
        f_eval(1)={'tr_args=''{conds.c_perms{i,:}};'};
        f_eval(2)={'trial=fetch_trial(p_ID{j},tr_args);'};
        %         f_eval(3)={'title_str=strjoin(conds.c_perms{i,:});'};% title of the figure
        title_str='strjoin(conds.c_perms{i,:});';
        f_eval(3)={'str=sprintf(''Participant %s'',p_ID{j});'};% title of the plot
        
    end
    
    a=length(f_eval);
    %alter data based on time, fft or means
    if (plot_type==1) % time domain
        f_eval(a+1)={'x_dat=trial{:,1} - trial{1,1};'};
        f_eval(a+2)={'y_dat=trial{:,data_col};'};
        
        xlab='Time';
        
        
    elseif (plot_type==2)% fft
        
        z_pad=input('what sample would you like to zero pad out to: ');
        sr=input('What is the sample rate: ');
        f_eval(a+1)={'x_dat=linspace(0,sr,z_pad);'};
        f_eval(a+2)={'y_dat=abs(fft(trial{:,data_col}))'';'};
        f_eval(a+3)={'y_dat=y_dat(length(y_dat)+1:z_pad)=0;'};
        
        xlab='Frequency(Hz)';
        
        
    elseif (plot_type==3)% means and std
        count=1;
        xlab='Time';
        f_eval(a+1)={'x_dat=trial{:,1} - trial{1,1};'};
        f_eval(a+1)={'y_dat=trial{:,data_col};'};
        % more evals are done in a seperate loop
        
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% actually plot data
    if (plot_type~=3) % means and std uses different plots
        for i=1:i_end
            temp_fig=figure;
            hold on
            index=1;
            
            for j=1:j_end
                
                for eval_index=1:length(f_eval)
                    eval(f_eval{eval_index});
                end
                
                subplot(sub_layout(1), sub_layout(2), index)
                plot(x_dat,y_dat)
                index=index+1;
                
                title(str)
                xlabel(xlab)
                ylabel(trial.Properties.VariableNames(data_col))
                xlim([min(x_dat), max(x_dat)])
                ylim(y_lims)
                
                clearvars trial time str
            end
            
            %         hold off
            temp_fig;
            str=eval(title_str);
            %str=sprintf('%s',p_ID{i});
            %title(str)
            if (auto_save)
                fID=strcat(figure_save_path,'\', str, '.jpg');
                set(temp_fig,'PaperUnits','inches','PaperPosition',resolution);
                print('-djpeg','-r100',fID)
                close(temp_fig)
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% means and std
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Find the mean and std for every trial sorted by participant
    else
        %%%%%%%%%
        means_bar_format=zeros(i_end,j_end);
        std_bar_format=zeros(i_end,j_end);
        for i=1:i_end
            index=1;
            
            for j=1:j_end
                %% load trial etc...
                for eval_index=1:length(f_eval)
                    eval(f_eval{eval_index});
                end
                
                %%%% evals
                raw_means(count,:)={p_ID(i),tr_args{:},mean(y_dat),std(y_dat)};
                
                means_bar_format(i,j)=mean(y_dat);
                std_bar_format(i,j)=std(y_dat);
                
                count=count+1;
                %%%%
                
                if ((i==1)&&(j==1))% create header and filename for the table
                    header={'Participant',conditions{:},'Mean','Standard_dev'};
                    foo=trial.Properties.VariableNames(data_col);
                    m_filename=sprintf('%s_means',foo{1});
                    s_filename=sprintf('%s_std',foo{1});
                    str_title=sprintf('%s Means',char(trial.Properties.VariableNames(data_col)));
                end
                if (i==1)% create the legend
                    if (plot_by==1)% oganize by participants
                        leg_str(j)={strjoin(tr_args)};
                    else % organize by trial
                        leg_str(j)=p_ID{i};
                    end
                end
                if (j==1)% create tick labels for the bar plot
                    if (plot_by==1)% oganize by participants
                        specs(i)=p_ID(i);
                    else % organize by trial
                        specs(i)={strjoin(tr_args)};
                    end
                end
                clearvars trial y_dat x_dat
            end
        end
        %%%%%%%%%
        pupil_means=cell2table(raw_means);
        pupil_means.Properties.VariableNames = header;
        
        %% work on plotting this!!!!!
        
        % plot means
        temp_fig=figure;
        bar(means_bar_format)
        legend(leg_str,'Location','EastOutside')
        title(str_title)
        set(gca,'XTickLabel',specs, 'XTick',1:numel(specs));
        
        % save bar graph
        if (auto_save)
            fID=strcat(figure_save_path,'\', m_filename, '.jpg');
            set(temp_fig,'PaperUnits','inches','PaperPosition',resolution);
            print('-djpeg','-r100',fID)
            close(temp_fig)
            %% save means table
            file_name=strcat(figure_save_path,'\', m_filename, '.csv');
            writetable(pupil_means,file_name);
            
        end
        
        % plot std
        temp_fig=figure;
        bar(std_bar_format)
        str_title=strrep(str_title,'means','STDs');
        legend(leg_str,'Location','EastOutside')
        title(str_title)
        set(gca,'XTickLabel',specs, 'XTick',1:numel(specs));
        
        % save bar graph
        if (auto_save)
            fID=strcat(figure_save_path,'\', s_filename, '.jpg');
            set(temp_fig,'PaperUnits','inches','PaperPosition',resolution);
            print('-djpeg','-r100',fID)
            close(temp_fig)
        end
        
        
        
    end
    
    
end
end
