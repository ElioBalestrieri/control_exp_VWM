function out = do_abort(out)

msg1 = ['Escape Key pressed:\n'...
        'Do you want to interrupt the current block?\n'...
        '"Y" -> will interrupt the block\n'...
        '"N" -> will continue the experiment from the next trial\n'];

no_resp = true;

while no_resp

    Screen('FillRect',out.P.win, out.P.grey)
    % dx cue response
    DrawFormattedText(out.P.win, msg1)
    Screen('Flip',out.P.win);

    [~, ~, code] = KbCheck;
    
    if find(code)==out.P.nKey
        
        return
        
    elseif find(code)==out.P.yKey 
        
        % bring trial n to end
        out.trlcount = out.P.ntrlsblock;

        if isfield(out, 'FLAGpractice')
            
            return
            
        end
        
        WaitSecs(.5)
        
        no_resp2 = true;
        while no_resp2
            
            
            msg2 = ['OK, you decided to interrupt the current block\n'...
                    'Now be careful:\n'...
                    'Do you want to interrupt the Experiment?\n'...
                    '"Y" -> the experiment will stop\n'...
                    '"N" -> the experiment will restart from the next block (or module)'];

            Screen('FillRect',out.P.win, out.P.grey)
            % dx cue response
            DrawFormattedText(out.P.win, msg2)
            Screen('Flip',out.P.win);

            [~, ~, code2] = KbCheck;

            if find(code2)==out.P.yKey
                
                % here bring the block n to the end
                out.blockcount = out.P.nblocks;
                out.FLAGabort = true;
                
                return

            elseif find(code2)==out.P.nKey

                return

            end
            
        end
        
    end
        
end
        


end