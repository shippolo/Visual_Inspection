%% Created by Micah Lucas for educational purposes, 2016.
%  UBICOMP_load_eye_data.m: load eye tracking data from user selected files
%  Loads each participant's data as a table and saves/appends each to a
%  global "participant" structure.ie,"participant.p01","participant.p02"...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global p_ID participant conditions


%% select files
[FileName,PathName,FilterIndex] = uigetfile('.csv','Select eye data to load','Multiselect','on');
cond_cols=input('Enter the columns that contain conditions (as a matlab vector): ');


%% determine participant IDs
p_ID=cell(1,length(FileName));
for i=1:length(FileName)
    [~,temp]=strtok(FileName(i),'_');
    [p_ID(i),~]=strtok(temp,'_');
    if(isempty(p_ID{i}))
        [p_ID(i),~]=strtok(FileName(i),'.');
    end
end

%% init vars
%% to improve load times you can choose to only load the columns you want
col_check=0;
need_fspec=0;

%% Import the data
% t1=tic;
for i=1:length(p_ID)
    fprintf('Loading data for participant %s\n',p_ID{i})
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Initialize variables.
    delimiter = ',';
    
    startRow = 1;
    endRow = inf;
    f_ID=strcat(PathName,FileName{i});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %% determine format spec
    if(need_fspec==0)
        need_fspec=1;
        fid=fopen(f_ID);
        temp=fgetl(fid);%read in the first line
        foo=regexprep(temp,'[^,]','');% remove everything that isn't a ","
        foo=strcat(',',foo);% add one comma
        %% Read columns of data as strings:
        formatSpec=strrep(foo,',','%s');
        
        fclose(fid);
        clearvars fid temp foo
    end
    %%%%%%%%%%%%%%%%%%%%%
    
    
    %% Open the text file.
    fileID = fopen(f_ID,'r');
    
    %% Read columns of data according to format string.
    dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
    for block=2:length(startRow)
        frewind(fileID);
        dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
        for col=1:length(dataArray)
            dataArray{col} = [dataArray{col};dataArrayBlock{col}];
        end
    end
    %% Close the text file.
    fclose(fileID);
    
    %% table column labels
    header=cell(1,length(dataArray));
    for head=1:length(dataArray)
        header{head}=dataArray{head}{1};
        header(head)=regexprep(header(head),'\W','');
        dataArray{head}=dataArray{head}(2:end);
        
    end
    for rep_quotes=1:length(dataArray)
        dataArray{rep_quotes}(:)=strrep(dataArray{rep_quotes}(:),'"',''); % remove any random "s
        dataArray{rep_quotes}(:)=strrep(dataArray{rep_quotes}(:),'''',''); % remove any random 's
    end
    
    
    %% determine numeric cells
    if (col_check==0)
        col_check=1;
        num_cols=[];
        for head=1:length(dataArray)
            cell_contents=dataArray{head}{1};
            num=isstrprop(cell_contents,'digit');
            if ((length(num)-sum(num))<=2)
                num_cols=[num_cols,head];
            end
            
        end
        
    end
    
    

    
    
    %% Convert the contents of columns containing numeric strings to numbers.
    % Replace non-numeric strings with NaN.
    raw = repmat({''},length(dataArray{1}),length(dataArray));
    for col=1:length(dataArray)
        raw(1:length(dataArray{col}),col) = dataArray{col};
    end
    
    
    numericData = NaN(size(dataArray{1},1),size(dataArray,2));
    
    
    for col=num_cols
        % Converts strings in the input cell array to numbers. Replaced non-numeric
        % strings with NaN.
        rawData = dataArray{col};
        for row=1:size(rawData, 1);
            % Create a regular expression to detect and remove non-numeric prefixes and
            % suffixes.
            regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
            try
                result = regexp(rawData{row}, regexstr, 'names');
                numbers = result.numbers;
                
                % Detected commas in non-thousand locations.
                invalidThousandsSeparator = false;
                if any(numbers==',');
                    thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                    if isempty(regexp(thousandsRegExp, ',', 'once'));
                        numbers = NaN;
                        invalidThousandsSeparator = true;
                    end
                end
                % Convert numeric strings to numbers.
                if ~invalidThousandsSeparator;
                    numbers = textscan(strrep(numbers, ',', ''), '%f');
                    numericData(row, col) = numbers{1};
                    raw{row, col} = numbers{1};
                end
            catch me
            end
        end
    end
    
    %% Split data into numeric and cell columns.
    rawNumericColumns = raw(:, num_cols);
    raw(:,cond_cols)=strrep(raw(:, cond_cols),'"',''); % remove any random "s
    raw(:,cond_cols)=strrep(raw(:, cond_cols),'''',''); % remove any random 's
    rawCellColumns = raw(:, cond_cols);
    
    
    %% Replace non-numeric cells with NaN
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
    rawNumericColumns(R) = {NaN}; % Replace non-numeric cells
    
    %% Allocate imported array to column variable names
    
    participant.(sprintf('%s',p_ID{i})) =cell2table(raw);
    participant.(sprintf('%s',p_ID{i})).Properties.VariableNames = header;
    
    %% clear temp variables
    clearvars block col dataArray delimiter endRow f_ID fileID ...
        head invalidThousandsSeparator me numbers numericData raw rawCellColumns...
        rawData rawNumericColumns regexstr result row startRow temp R header...
        
    fprintf('done loading %s\n',p_ID{i})
    
%     if(i==1)
%         t2=toc;
%         t_elapsed=(t2-t1)/1000;
%         t_projected=length(p_ID)*t_elapsed;
%         fprintf('First participant took %d seconds.\n Estimated %d seconds to load all data.\n',t_elapsed,t_projected)
%     end
    
    %     end
end

conditions=participant.(sprintf('%s',p_ID{1})).Properties.VariableNames(cond_cols);%columns 2 and 3 are conditions
conditions=strrep(conditions,'"','');



clearvars PathName FileName i participant_resp