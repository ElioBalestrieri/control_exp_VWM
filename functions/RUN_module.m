function out = RUN_module(argstr, macro)
% run each experimental module according 
out.which_module = argstr;
out.macro = macro;

out = do_PARAMS(out);

try
        
    for iBlock = 1:out.P.nblocks
        
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
        
    end
    
catch ME
    
    ListenChar(0)
    PsychPortAudio('Close', out.P.pahandle);
    sca 

end

ListenChar(0)
PsychPortAudio('Close', out.P.pahandle);
sca 

end