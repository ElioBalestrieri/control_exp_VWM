function varargout = HELPER_functions(argstr, varargin)

switch argstr
    
    case 'setpaths'
       
        varargout{1} = local_SETPATH;
        
    case 'savefile'
        
        M = varargin{1};
        local_SAVEFILE(M);
        
end


end

%% ######################### LOCAL FUNCTIONS ##############################

function out = local_SETPATH
%% Open GUI to obtain data from participant
prompt = {'Participant Number', 'Initials', 'run VWM evaluation?',...
    'run QUEST?', 'run main EXP?', 'starting block', 'ending block'};
dlg_title = 'VWM & attention';
definput = {'00', 'AA', 'no', 'yes', 'yes', '1', '6'};
num_lines = 1;
subj_answer = inputdlg(prompt,dlg_title,num_lines,definput);
subj_answer{1} = num2str(str2double(subj_answer{1}), '%02d');

% define logical flags for how to run the experiment
out.FLAG.VWM = strcmpi(subj_answer{3}, 'yes');
out.FLAG.QUEST = strcmpi(subj_answer{4}, 'yes');
out.FLAG.EXP = strcmpi(subj_answer{5}, 'yes');

out.strtblck = str2double(subj_answer{6});
out.endblck = str2double(subj_answer{7});

%% paths definition
out.script_path = pwd; cd ..; out.root_path = pwd; cd scripts;     % obtain info about working dir specific to the current filesystem
addpath(genpath('/home/elio/toolboxes/Psychtoolbox-3-PTB_Beta-2019-02-07_V3.0.15/Psychtoolbox')) % add ptb -unnecessary in LAB -?-
addpath(genpath(fullfile(out.script_path, 'functions')))               % add functions folder
out.subjID = cat(2,subj_answer{1:2});                                  % concatemnate code and initials

% define path for data, common for eyetracking and behavioural data
out.data_path = fullfile(out.root_path, 'data', out.subjID);                
if ~isfolder(out.data_path); mkdir(out.data_path); end             % create folder if non existing

end

function local_SAVEFILE(M)

switch M.which_module
    
    case 'QUEST'
    
        filename = [M.which_module '.mat'];
        
    otherwise
        
        ts = datestr(now, 30);
        filename = [M.macro.subjID, M.which_module, ts, '.mat'];
        
end

save(fullfile(M.macro.data_path, filename), 'M')

end