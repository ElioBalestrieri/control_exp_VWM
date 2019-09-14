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

function foo = local_do_instructionsQUEST(foo)

corrPosQuad = [0 -300];

[swapMatWelcome, welcX1, welcY1] = drawFlash_gaussian(foo.P.pxlScreen(1),...
    foo.P.pxlScreen(2),...
    0.2, radiusFLASH, foo.P.grey, 2000, corrPosQuad);

squareFLASH1 = [welcX1-radiusFLASH, welcY1-radiusFLASH,...
            welcX1+radiusFLASH, welcY1+radiusFLASH];

indxMatWelcome = Screen('MakeTexture', window, uint8(swapMatWelcome*255));

Screen('DrawTexture', window, indxMatWelcome, squareFLASH1, squareFLASH1);



% draw welcome message
Screen('TextSize', window, 30);
Screen('TextFont', window, 'Tahoma');
welMsg0='Questo � il tuo target:';
welMsg2='Individua la porzione di schermo in cui lo vedi comparire:';
%welMsg3='risposte possibili: {I, O, L, K}';
welMsg4='Premi un tasto qualsiasi per continuare';

DrawFormattedText( window, 'O',xCoorPrompt(1), yCoorPrompt(4),  black);
DrawFormattedText( window, 'I',xCoorPrompt(2), yCoorPrompt(3),  black);
DrawFormattedText( window, 'K',xCoorPrompt(3), yCoorPrompt(2),  black);
DrawFormattedText( window, 'L',xCoorPrompt(4), yCoorPrompt(1),  black);
Screen('DrawLine', window, black, xyScreen(1)/2,yCoorPrompt(2),...
    xyScreen(1)/2,yCoorPrompt(3));
Screen('DrawLine', window, black, xCoorPrompt(3), xyScreen(2)/2,...
    xCoorPrompt(4), xyScreen(2)/2);


DrawFormattedText(window, welMsg0, 'center', xyScreen(2)/2-400,black);
DrawFormattedText(window, welMsg2, 'center', xyScreen(2)/2-200, black);
%DrawFormattedText(window, welMsg3, 'center', xyScreen(2)/2+250, black);
DrawFormattedText(window, welMsg4, 'center', xyScreen(2)/2+350, black);


vbl = Screen('Flip', window);









end
