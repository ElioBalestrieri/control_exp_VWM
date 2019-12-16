function foo = do_PRACTICE(out)

foo = out;
foo.FLAGpractice = true;
foo.blockcount = 1;
npracticetrials = 12;
npractice_QUEST = 5;

switch foo.which_module

    case 'VWM'
        
        foo = local_do_instructionsVWM(foo);
        
        trls = randsample(foo.P.ntrlsblock, npracticetrials)';
        
        itrl = 1;
        
        while itrl <= npracticetrials
            
            this_trl = trls(itrl);
            foo.trlcount = this_trl;
            foo = do_trial_VWM(foo);
            
            if foo.trlcount == foo.P.ntrlsblock
                
                foo.repeatpractice = false;
                return

            elseif foo.trlcount == this_trl-1
                itrl = itrl-1;
            
            else
                itrl = itrl+1;
            end
                
        end

    case 'QUEST'

        foo = local_do_instructionsQUEST(foo);
        
        % in QUEST's case the best solution for practice could be to 
        % not to update the first 5 t        
        itrl = 1;
        while itrl <= npractice_QUEST
            
            foo.trlcount = itrl;
            
            foo = do_trial_QUEST(foo);
            
            if foo.trlcount == foo.P.ntrlsblock
                
                foo.repeatpractice = false;
                return

            elseif foo.trlcount == itrl-1
                
                itrl = itrl-1;
            
            else
                
                itrl = itrl+1;
            
            end

            
        end
        
        


    case 'EXP'
                    
        foo = local_do_instructionsEXP(foo);
        
        trls = randsample(foo.P.ntrlsblock, npracticetrials)';
        
        itrl = 1;
        
        while itrl <= npracticetrials
            
            this_trl = trls(itrl);
            foo.trlcount = this_trl;

            foo = do_trial_EXP(foo);
            
                   
            if foo.trlcount == foo.P.ntrlsblock
                
                foo.repeatpractice = false;
                return

            elseif foo.trlcount == this_trl-1
                itrl = itrl-1;
            
            else
                itrl = itrl+1;
            end
                
        end
        
end

%% give a message of end practice
msg_end_practice = ['Practice is over!\n'...
    'Please remain AS STILL AS POSSIBLE so that we do not need recalibration...\n'...
    '"Y" -> will make you you want to REPEAT practice\n'...
    '"N" -> will START the experiment\n'];

no_resp = true;

while no_resp

    Screen('FillRect',foo.P.win, foo.P.grey)
    DrawFormattedText(foo.P.win, msg_end_practice, [], [], foo.P.black)
    Screen('Flip',foo.P.win);

    [~, ~, code] = KbCheck;
    
    if find(code)==foo.P.nKey
        
        foo.repeatpractice = false;
        return
        
    elseif find(code)==foo.P.yKey 
        
        foo.repeatpractice = true;
        return
        
    end
    
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
        'You will have to keep the colours in mind and keep fixating the circle'];
    
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

corrPosQuad = [0 0];

[swapMatWelcome, welcX1, welcY1] = drawFlash_gaussian(foo.P.pxlScreen(1),...
    foo.P.pxlScreen(2)/2-150,...
    .2, foo.P.radiusFLASH, .5, 2000, corrPosQuad);

squareFLASH1 = [welcX1-foo.P.radiusFLASH, welcY1-foo.P.radiusFLASH,...
            welcX1+foo.P.radiusFLASH, welcY1+foo.P.radiusFLASH];

indxMatWelcome = Screen('MakeTexture', foo.P.win, uint8(swapMatWelcome*255));

Screen('DrawTexture', foo.P.win, indxMatWelcome, squareFLASH1, squareFLASH1);

% draw welcome message
Screen('TextSize', foo.P.win, 30);
Screen('TextFont', foo.P.win, 'Tahoma');
welMsg0='Questo � il tuo target:';
welMsg2='Individua la porzione di schermo in cui lo vedi comparire:';
%welMsg3='risposte possibili: {I, O, L, K}';
welMsg4='Premi un tasto qualsiasi per continuare';

DrawFormattedText( foo.P.win, 'O',foo.P.xCoorPrompt(1), foo.P.yCoorPrompt(4), foo.P.black);
DrawFormattedText( foo.P.win, 'I',foo.P.xCoorPrompt(2), foo.P.yCoorPrompt(3),  foo.P.black);
DrawFormattedText( foo.P.win, 'K',foo.P.xCoorPrompt(3), foo.P.yCoorPrompt(2),  foo.P.black);
DrawFormattedText( foo.P.win, 'L',foo.P.xCoorPrompt(4), foo.P.yCoorPrompt(1),  foo.P.black);
Screen('DrawLine', foo.P.win, foo.P.black, foo.P.pxlScreen(1)/2,foo.P.yCoorPrompt(2),...
    foo.P.pxlScreen(1)/2,foo.P.yCoorPrompt(3));
Screen('DrawLine', foo.P.win, foo.P.black, foo.P.xCoorPrompt(3), foo.P.pxlScreen(2)/2,...
    foo.P.xCoorPrompt(4), foo.P.pxlScreen(2)/2);


DrawFormattedText(foo.P.win, welMsg0, 'center', foo.P.pxlScreen(2)/2-400, foo.P.black);
DrawFormattedText(foo.P.win, welMsg2, 'center', foo.P.pxlScreen(2)/2-200, foo.P.black);
%DrawFormattedText(foo.P.win, welMsg3, 'center', xyScreen(2)/2+250, black);
DrawFormattedText(foo.P.win, welMsg4, 'center', foo.P.pxlScreen(2)/2+350, foo.P.black);


Screen('Flip', foo.P.win);

KbStrokeWait


end

function foo = local_do_instructionsEXP(foo)

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
        'You will have to keep the colours in mind and keep fixating the circle'];
    

Screen('FillRect',out.P.win, out.P.grey)
Screen('FrameArc', out.P.win, [0 0 0], out.P.rect_cue, 0, 360, 4,4)
DrawFormattedText(out.P.win, msg3, 'center', out.P.yCenter-300)
DrawFormattedText(out.P.win, msgPress, 'center', out.P.yCenter+300)
Screen('Flip',out.P.win);

KbStrokeWait;


msg3bis = ['In some trials a flash might appear.\n'...
        'Your second task is to detect this flash.\n'...
        'It can occupy different positions inside the circle'];
 
[swapMatWelcome, welcX1, welcY1] = drawFlash_gaussian(out.P.rect(3),...
    out.P.rect(4), .25, out.P.radiusFLASH,...
    .5, 2000, out.P.yxFLASHnoise);
    
squareFLASH1 = [welcX1-foo.P.radiusFLASH, welcY1-foo.P.radiusFLASH,...
            welcX1+foo.P.radiusFLASH, welcY1+foo.P.radiusFLASH];

indxMatWelcome = Screen('MakeTexture', foo.P.win, uint8(swapMatWelcome*255));

    
Screen('FillRect',out.P.win, out.P.grey)
Screen('FrameArc', out.P.win, [0 0 0], out.P.rect_cue, 0, 360, 4,4)
DrawFormattedText(out.P.win, msg3bis, 'center', out.P.yCenter-300)
DrawFormattedText(out.P.win, msgPress, 'center', out.P.yCenter+300)
Screen('DrawTexture', foo.P.win, indxMatWelcome, squareFLASH1, squareFLASH1);

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
