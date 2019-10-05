%% Perform VWM and Attention control exp

clear all %#ok<CLALL>
close all
clc

%% open dialog and set path for current subject

macro = HELPER_functions('setpaths');

%% VWM part
if macro.FLAG.VWM
    M_vwm = RUN_module('VWM', macro);
    HELPER_functions('savefile', M_vwm)
    
    % abort?
    if isfield(M_vwm, 'FLAGabort')
        if M_vwm.FLAGabort
            error('The user requested to interrupt the experiment')
        end
    end
    
    infoMSG = {'VWM block completed successfully!',...
        'Shall we proceed to the QUEST?'};
    waitfor(msgbox(infoMSG,'Help','help'));

    
end   
    
%% QUEST part
if macro.FLAG.QUEST 
    
    isquestOK = false;
    
    while ~isquestOK
        
        M_quest = RUN_module('QUEST', macro);
        
        % abort?
        if isfield(M_quest, 'FLAGabort')
            if M_quest.FLAGabort
                error('The user requested to interrupt the experiment')
            end
        end
        
        [isquestOK, contrast] = HELPER_functions('contrast', M_quest);
        
    end
    
    HELPER_functions('savefile', M_quest)
    macro.contrast = contrast;
    
    infoMSG = {'QUEST block completed successfully!',...
        'Shall we proceed to the main experiment?'};
    waitfor(msgbox(infoMSG,'Help','help'));

else
    
    %% manual contrast definition
    
    % first give a warning message
    warnMSG = {'WARNING!', 'No QUEST has been run',...
        'Press OK to navigate to the window for contrast selection'};
    waitfor(msgbox(warnMSG,'Warn','warn'));
    
    %... then open dialog window
    dlg_title = 'no QUEST run: which contrast?';
    prompt = {'contrast'};
    definput = {num2str(.15)};
    subj_answer = inputdlg(prompt,dlg_title,1,definput); 
    
    macro.contrast = str2double(subj_answer{1});
    
end

%% realexp part
if macro.FLAG.EXP
    
    if macro.contrast>.25 || macro.contrast<.05
        error('improbable contrast value')
    end
    
    M_EXP = RUN_module('EXP', macro);
    HELPER_functions('savefile', M_EXP)

end