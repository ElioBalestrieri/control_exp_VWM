function out = RUN_module(argstr, macro)
% run each experimental module according 
out.which_module = argstr;
out.macro = macro;

if isfield(macro, 'contrast')
    out = do_PARAMS(out, macro.contrast);
else
    out = do_PARAMS(out);
end

% prepare Eye-tracking input
out = do_PARAMS_ET(out);

out.eyelinkconnected = true;
iBlock = 1;

try

    if out.eyelinkconnected
        [out.E, ~] = EyelinkStart(out.E, out.P.win, ...
            [macro.subjID '_' argstr(1:3)], out.eyelinkconnected);    
    end

    
    %% start every module with a small (12 trials) practice block
    repeat_practice = true;
    while repeat_practice
        foo = do_PRACTICE(out);
        repeat_practice = foo.repeatpractice;
    end
    
    while iBlock <= out.P.nblocks
        
        out.blockcount = iBlock;
        out.trlcount = 1;
        
        while out.trlcount <= out.P.ntrlsblock

            switch argstr

                case 'VWM'
                    
                    out = do_trial_VWM(out);
                    
                case 'QUEST'

                    out = do_trial_QUEST(out);
                    
                case 'EXP'
                    
                    out = do_trial_EXP(out);
                    
            end
        
            smallbreakflag = mod(out.trlcount, 40)==0;
            blockbreakflag = out.trlcount == out.P.ntrlsblock;
            
            if smallbreakflag && ~blockbreakflag
                        
                local_do_small_break(out);
            
            end
            
            out.trlcount = out.trlcount+1;
            
        end
        
        iBlock = out.blockcount; % if the block was aborted
        iBlock = iBlock +1;
        
        % save block
        HELPER_functions('savefile', out)

        % longer break
        local_do_longer_break(out);
        
    end
    
catch ME
    
    ListenChar(0)
    dircrashes = fullfile(out.macro.root_path, 'crashlog');
    if ~isfolder(dircrashes); mkdir(dircrashes); end
    ts = datestr(now, 30);
    save(fullfile(dircrashes, ['crash_' ts '.mat']), 'ME')
        
    HELPER_functions('savefile', out)
    
    
    if out.eyelinkconnected
        EyelinkStop(out.E, out.eyelinkconnected, out.E.EDFdir);  
            HELPER_functions('savefile', out)
    end
    
    if isfield(out.P, 'pahandle')
        PsychPortAudio('Close', out.P.pahandle);
        
    end
    sca 
    
    rethrow(ME)
    
end

if out.eyelinkconnected
    EyelinkStop(out.E, out.eyelinkconnected, out.E.EDFdir);  
end

ListenChar(0)

if isfield(out.P, 'pahandle')
    PsychPortAudio('Close', out.P.pahandle);
end
sca 

end


%% #################### LOCAL FUNCTIONS

function local_do_small_break(out)

if strcmp(out.which_module, 'QUEST')
    return
end


msg = ['other 40 trials done: time for a small break\n'...
       'You can stay still and proceed with the experiment when you are ready\n'...
       'by pressing any key\n'...
       '\nOR\n\n'...
       'you can move, but then jump into recalibration by pressing "ESC"'];
   
no_resp = true;
WaitSecs(.1)
while no_resp

    Screen('FillRect',out.P.win, out.P.grey)
    % dx cue response
    DrawFormattedText(out.P.win, msg, 'center', 'center')
    Screen('Flip',out.P.win);

    [kdown, ~, code] = KbCheck;
    
    if kdown
        if find(code)==out.P.escapeKey

            % do recalibration
            if out.eyelinkconnected
                EyelinkRecalibration(out.E, out.eyelinkconnected)
            end


        else

            return


        end
    end
    
end



end

function local_do_longer_break(out)

fexp = false;

switch out.which_module
    
    case 'EXP'

        msg = ['You finished block ' num2str(out.blockcount) ': time for a break!\n'...
               'You can stay still and proceed with the experiment when you are ready\n'...
               'by pressing any key\n'...
               '\nOR\n\n'...
               'you can move, but then jump into recalibration by pressing "ESC"\n'...
               '\nThe SECOND option is recommended :D'];
        
        fexp = true;

    case 'QUEST'
        
        msg = ['Great, you finished the second part of the experiment!'...
            '\nPress any button to continue'];
        
        
    case 'VWM'
        
        msg = ['Congrats, you finished the first part of the experiment!'...
            '\nPress any button to move to the next one'];
                
end
        
        
no_resp = true;
WaitSecs(.1)
while no_resp

    Screen('FillRect',out.P.win, out.P.grey)
    % dx cue response
    DrawFormattedText(out.P.win, msg, 'center', 'center')
    Screen('Flip',out.P.win);

    [kdown, ~, code] = KbCheck;
    
    if kdown
        
        if (find(code)==out.P.escapeKey) && fexp

            % do recalibration
            if out.eyelinkconnected
                EyelinkRecalibration(out.E, out.eyelinkconnected)
            end


        else

            return


        end

    end
end



end