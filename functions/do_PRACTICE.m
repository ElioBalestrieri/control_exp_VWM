function out = do_PRACTICE(out)

foo = out;

switch foo.which_module

    case 'VWM'
        
        foo = local_do_instructionsVWM(foo);
%         foo = do_trial_VWM(foo);

    case 'QUEST'

        foo = local_do_instructionsQUEST(foo);
%         foo = do_trial_QUEST(foo);

    case 'EXP'
                    
%         foo = do_trial_EXP(foo);
           
end

end

%% ######################## LOCAL FUNCTIONS #############################

function foo = local_do_instructionsVWM(foo)

out = foo;

swap_color = out.P.colormap(randsample(1:6,5,'false'),:)';
cr.which_cols1 = swap_color(:,1:4);


msg1 = ['Every trial will start with a circle.\n'...
        'You will have to maintain fixation inside this circle'];
    
msgPress = 'Press a button to continue';

Screen('FillRect',out.P.win, out.P.grey)
Screen('FrameArc', out.P.win, [0 0 0], out.P.rect_cue, 0, 360, 4,4)
DrawFormattedText(out.P.win, msg1, 'center', out.P.yCenter-300)
DrawFormattedText(out.P.win, msgPress, 'center', out.P.yCenter+300)
Screen('Flip',out.P.win);

KbStrokeWait;

msg2 = '4 colored squares will appear...';

Screen('FillRect',out.P.win, out.P.grey)
Screen('FrameArc', out.P.win, [0 0 0], out.P.rect_cue, 0, 360, 4,4)
DrawFormattedText(out.P.win, msg2, 'center', out.P.yCenter-300)
DrawFormattedText(out.P.win, msgPress, 'center', out.P.yCenter+300)
Screen('FillRect', out.P.win, cr.which_cols1, out.P.square_pos)

Screen('Flip',out.P.win);

KbStrokeWait;

msg3 = ['The squares will be followed by a blank interval.\n'...
        'You will have to keep the colours in mind and keep fixating the square'];
    
msgPress = 'Press a button to continue';

Screen('FillRect',out.P.win, out.P.grey)
Screen('FrameArc', out.P.win, [0 0 0], out.P.rect_cue, 0, 360, 4,4)
DrawFormattedText(out.P.win, msg3, 'center', out.P.yCenter-300)
DrawFormattedText(out.P.win, msgPress, 'center', out.P.yCenter+300)
Screen('Flip',out.P.win);

KbStrokeWait;

msg4 = ['4 colored squares will appear again\n'...
        'Your task will be to say whether they are equal("M")\n'...
        'or different ("Z")'];

Screen('FillRect',out.P.win, out.P.grey)
Screen('FrameArc', out.P.win, [0 0 0], out.P.rect_cue, 0, 360, 4,4)
DrawFormattedText(out.P.win, msg4, 'center', out.P.yCenter-300)
DrawFormattedText(out.P.win, msgPress, 'center', out.P.yCenter+300)
Screen('FillRect', out.P.win, cr.which_cols1, out.P.square_pos)

Screen('Flip',out.P.win);

KbStrokeWait;

Screen('FillRect',out.P.win, out.P.grey)
DrawFormattedText(out.P.win, 'Ready to go?\nPress a button if so.', 'center', 'center')
Screen('Flip',out.P.win);

KbStrokeWait;


end
