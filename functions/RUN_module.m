function out = RUN_module(argstr, macro)
% run each experimental module according 
out.which_module = argstr;
out.macro = macro;

if isfield(macro, 'contrast')
    out = do_PARAMS(out, macro.contrast);
else
    out = do_PARAMS(out);
end

iBlock = 1;

try
    
    %% start every module with a small (12 trials) practice block
    do_PRACTICE(out);
    
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
        
    end
    
catch ME
    
    ListenChar(0)
    if isfield(out.P, 'pahandle')
        PsychPortAudio('Close', out.P.pahandle);
    end
    sca 
    
    rethrow(ME)
    
end

ListenChar(0)
if isfield(out.P, 'pahandle')
    PsychPortAudio('Close', out.P.pahandle);
end
sca 

end