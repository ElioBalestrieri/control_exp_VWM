function out = do_fixcontrol(out)

% put current trial condition to the end of the experiment/block
if ~strcmp(out.which_module, 'QUEST')
    
    out.P.B(out.blockcount).which_cond(end+1, :) = ...
        out.P.B(out.blockcount).which_cond(out.trlcount, :);
    
end

% come back of one trial (it will be updated to +1 after return)
out.trlcount = out.trlcount -1;

% update to +1 the fix breaks
out.fixbreak = out.fixbreak +1;

% give the participant a feedback for the fixation break
msg_feed = ['Fixation break detected:\n'...
    'We will have to repeat the trial...\n'...
    'Sorry for that :(\n'];

Screen('FillRect',out.P.win, out.P.grey)
% dx cue response
DrawFormattedText(out.P.win, msg_feed, 'center', 'center', out.P.black)
Screen('Flip',out.P.win);
WaitSecs(1)


%% check whether to jump into recalibration
if out.fixbreak >= 4
    
    msg1 = ['4 fixation breaks detected:\n'...
        'Do you want to jump into recalibration?\n'...
        '"Y" -> will perform recalibration, and restart the experiment from the next trial\n'...
        '"N" -> will simply continue the experiment from the next trial\n'...
        '"ESCape" -> exit exp options\n'];

    no_resp = true;

    while no_resp

        Screen('FillRect',out.P.win, out.P.grey)
        % dx cue response
        DrawFormattedText(out.P.win, msg1, 0, 0, out.P.black)
        Screen('Flip',out.P.win);

        [~, ~, code] = KbCheck;

        if find(code)==out.P.nKey

            no_resp = false;
            
        elseif find(code)==out.P.yKey 
            
            if out.eyelinkconnected
                EyelinkRecalibration(out.E, out.eyelinkconnected)
            end
            
            no_resp = false;
            
        elseif find(code) == out.P.escapeKey

            out = do_abort(out);
            
            no_resp = false;
            
        end
        
    end
    
    out.fixbreak = 0;
    
end

end