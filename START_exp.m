%% Perform VWM and Attention control exp

clear all %#ok<CLALL>
close all
clc

%% open dialog and set path for current subject

macro = HELPER_functions('setpaths');

%% run the three modules of the experiment

% VWM part
if macro.FLAG.VWM
    M_vwm = RUN_module('VWM', macro);
    HELPER_functions('savefile', M_vwm)
end

% QUEST part
if macro.FLAG.QUEST
    M_quest = RUN_module('QUEST', macro);
    HELPER_functions('savefile', M_quest)
end

% VWM part
if macro.FLAG.EXP
    M_EXP = RUN_module('EXP', macro);
    HELPER_functions('savefile', M_EXP)
end