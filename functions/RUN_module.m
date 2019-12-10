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

out.eyelinkconnected = false;
iBlock = 1;

try

    if out.eyelinkconnected
        [out.E, ~] = EyelinkStart(out.E, out.P.win, ...
            [macro.subjID '_' argstr], out.eyelinkconnected);    
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
        
           out.trlcount = out.trlcount+1;
            
        end
        
        iBlock = out.blockcount; % if the block was aborted
        iBlock = iBlock +1;
        
        % save block
        HELPER_functions('savefile', out)

        
    end
    
catch ME
    
    ListenChar(0)
    dircrashes = fullfile(out.macro.root_path, '.crashlog');
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