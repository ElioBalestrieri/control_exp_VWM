function main = RUN_trl(main, cr)

% define current load condition
condLoad = main.condLoad(cr.lLoop);
% define current cued positions
conPos = main.square_change(cr.lLoop,:);
% for while loop
waitResponse = false;

%% to save movie
% if cr.lLoop ==1
%     movieFile = 'moviefile';
%     main.movie = Screen('CreateMovie', main.win, movieFile)
% end

%% fixation -- 1 sec -- (100 frame @100Hz)

Screen('FillRect',main.win, main.grey)
cr.vbl = Screen('Flip',main.win, cr.vbl+.5*main.ifi);

base = GetSecs();
for frameL = cr.frames.fix
    
    Screen('FrameArc', main.win, [0 0 0], [main.xCenter-main.radiusFLASH/2,...
        main.yCenter-main.radiusFLASH/2, main.xCenter+main.radiusFLASH/2,...
        main.yCenter+main.radiusFLASH/2], 0, 360,2,2)
    cr.vbl = Screen('Flip',main.win, cr.vbl+.5*main.ifi);

% movie
%     if cr.lLoop==1
%         Screen('AddFrameToMovie',main.win);
%     end
     
end
tFix = GetSecs()-base;
main.timestamp(cr.lLoop, 1) = tFix;
%main.image_fix{cr.lLoop} = Screen('GetImage',main.win);


%% cue -- 200 msec -- (20 frame @100 Hz)

Screen('FillRect',main.win, main.grey)
%cr.vbl = Screen('Flip',main.win, cr.vbl+.5*main.ifi);

base = GetSecs();
for frameL = cr.frames.cue


    
    HELPER_cue(main, condLoad, conPos)
    cr.vbl = Screen('Flip',main.win, cr.vbl+.5*main.ifi);
    
%     if cr.lLoop==1
%         Screen('AddFrameToMovie',main.win);
%     end
    
end
tCue = GetSecs()-base;
main.timestamp(cr.lLoop, 2) = tCue;
%main.image_cue{cr.lLoop} = Screen('GetImage',main.win);

%% fixation post cue -- 200 ms -- (20 frames @100Hz)

Screen('FillRect',main.win, main.grey)
%cr.vbl = Screen('Flip',main.win, cr.vbl+.5*main.ifi);

base = GetSecs();
for frameL = cr.frames.post_cue
    
    HELPER_cue(main, 0, [])
    cr.vbl = Screen('Flip',main.win, cr.vbl+.5*main.ifi);
    
%     if cr.lLoop==1
%         Screen('AddFrameToMovie',main.win);
%     end
    
end
tFix = GetSecs()-base;
main.timestamp(cr.lLoop, 3) = tFix;


%% array -- 500 msec -- (50 frames @100 Hz) + beep

% Screen('FillRect',main.win, [128 128 128])
% cr.vbl = Screen('Flip',main.win, cr.vbl+.5*main.ifi);

base = GetSecs();
for frameL = cr.frames.squares
    
    HELPER_cue(main, 0, [])
    Screen('FillRect', main.win, cr.color1, main.square_pos)
    
    if frameL == cr.frames.squares(end-1)
        PsychPortAudio('Start', main.pahandle, main.repetition, 0, 1);
        % don't wait for sound to end 
%         [main.actualStartTime, ~, ~, main.estStopTime] = ...
%             PsychPortAudio('Stop', main.pahandle, 0, 0);

    end
    
    cr.vbl = Screen('Flip',main.win, cr.vbl+.5*main.ifi);
    
%     if cr.lLoop==1
%         Screen('AddFrameToMovie',main.win);
%     end
    
end
tArray = GetSecs()-base;
main.timestamp(cr.lLoop, 4) = tArray;
%main.image_array{cr.lLoop} = Screen('GetImage',main.win);


%% GAP -- delta t  -- waiting for flash

base = GetSecs();
for frameL = cr.frames.wait_before
    
    % draw grey screen
    Screen('FillRect',main.win, main.grey)
    
    HELPER_cue(main, 0, [])
    cr.vbl = Screen('Flip',main.win, cr.vbl+.5*main.ifi);
    
%     if cr.lLoop==1
%         Screen('AddFrameToMovie',main.win);
%     end
    
end
tArray = GetSecs()-base;
main.timestamp(cr.lLoop, 5) = tArray;

%% FLASH

base = GetSecs();
for frameL = cr.frames.flash

    Screen('DrawTexture', main.win, main.texture_FLASH, ...
        main.squareFLASH,main.squareFLASH);
    HELPER_cue(main, 0, [])
    
    % Flip to the screen
    cr.vbl = Screen('Flip', main.win, cr.vbl+.5*main.ifi);
    
%     if cr.lLoop==1
%         Screen('AddFrameToMovie',main.win);
%     end
    
end
tFlash = GetSecs()-base;
main.timestamp(cr.lLoop, 6) = tFlash;
%main.image_flash{cr.lLoop} = Screen('GetImage',main.win);


%% GAP -- 1-delta t -- waiting for test memory array

base = GetSecs();
for frameL = cr.frames.wait_after
    
    % draw grey screen
    Screen('FillRect',main.win, main.grey)
    
    HELPER_cue(main, 0, [])
    cr.vbl = Screen('Flip',main.win, cr.vbl+.5*main.ifi);
    
%     if cr.lLoop==1
%         Screen('AddFrameToMovie',main.win);
%     end
    
end
tArray = GetSecs()-base;
main.timestamp(cr.lLoop, 7) = tArray;



%% TEST ARRAY -- until response --

base = GetSecs();
while waitResponse==false
    
%     %debug square cuing
%     msg_debug = ['load ' num2str(main.condLoad(cr.lLoop)) 'cue '...
%         num2str(main.square_change(cr.lLoop,:))];
%     
%     DrawFormattedText(main.win,msg_debug,...
%         main.xCenter+600, main.yCenter-400, main.black);
    
    
    Screen('FillRect', main.win, cr.color2, main.square_pos)
    HELPER_cue(main, 0, [])
    % dx cue response
    DrawFormattedText(main.win, '"M" se uguale', main.xCenter+400, ...
        main.yCenter+350, main.black);
    % sx cue response
    DrawFormattedText(main.win, '"Z" se diverso', main.xCenter-610, ...
        main.yCenter+350, main.black);
    
    cr.vbl = Screen('Flip', main.win, cr.vbl+.5*main.ifi);
    
%     if cr.lLoop==1
%         Screen('AddFrameToMovie',main.win);
%     end
    
    [keyDown, ~, keyCode]=KbCheck;

    if keyDown==1
        code=find(keyCode);
        if code ==main.escapeKey
             waitResponse=true;
             sca;

        elseif code==main.zKey
            main.resp_MEM(cr.lLoop)=0; % z -> different = 0
            main.codeResp.memory(cr.lLoop) = code; % backup saving original keyboard code response
            waitResponse=true;

        elseif code==main.mKey
            main.resp_MEM(cr.lLoop)=1; % m -> equal = 1
            main.codeResp.memory(cr.lLoop) = code; % backup saving original keyboard code response
            waitResponse=true;


        end
        
    end

end
tResp = GetSecs()-base;
main.timestamp(cr.lLoop, 8) = tResp;
%main.image_test{cr.lLoop} = Screen('GetImage',main.win);


%% FLASH QUESTION --until response --

% draw grey screen --> ~ 200 ms to flush responses
Screen('FillRect',main.win, main.grey)
cr.vbl = Screen('Flip',main.win, cr.vbl+.5*main.ifi);
WaitSecs(.2)

waitResponse = false;
 
base = GetSecs();
while waitResponse==false
            
    % prompt response 2
    Screen('TextSize', main.win, 35);
    Screen('TextFont', main.win, 'Tahoma');
    DrawFormattedText(main.win, 'Flash Assente ("z") o Presente ("m")?',...
        'center', 'center', main.black);
     
    cr.vbl = Screen('Flip', main.win, cr.vbl+.5*main.ifi);
    
%     if cr.lLoop==1
%         Screen('AddFrameToMovie',main.win);
%     end
    
    [keyDown, ~, keyCode]=KbCheck;

    if keyDown==1
        code=find(keyCode);
        if code ==main.escapeKey
             waitResponse=true;
             sca;

        elseif code==main.zKey
            main.resp_FLASH(cr.lLoop)=0; % flash absent (z) = 0
            main.codeResp.flash(cr.lLoop) = code; % backup saving original keyboard code response
            waitResponse=true;

        elseif code==main.mKey
            main.resp_FLASH(cr.lLoop)=1; % flash present (m) = 1
            main.codeResp.flash(cr.lLoop) = code; % backup saving original keyboard code response
            waitResponse=true;


        end
        
   end

end
tResp = GetSecs()-base;
main.timestamp(cr.lLoop, 9) = tResp;

%main.image_test2{cr.lLoop} = Screen('GetImage',main.win);

% if cr.lLoop==1
%     
%     Screen('FinalizeMovie', main.movie)
% 
% end
    
 
end    
