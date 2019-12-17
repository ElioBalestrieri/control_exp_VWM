function out = do_trial_VWM(out)

% empty current (cr) structure
cr = [];
% define whether the array is changing
ischanging = out.P.B(out.blockcount).which_cond(out.trlcount,:);
% determine square colors for the present trial
swap_color = out.P.colormap(randsample(1:6,5,'false'),:)';
cr.which_cols1 = swap_color(:,1:4);

% determine color arrays
if ischanging==0
    cr.which_cols2 = cr.which_cols1;
else
    which_square = randi(4);
    cr.which_cols2 = cr.which_cols1;
    cr.which_cols2(:, which_square) = swap_color(:,end);
end

% for while loop
waitResponse = false;

%% to save movie
% if cr.lLoop ==1
%     movieFile = 'moviefile';
%     out.P.movie = Screen('CreateMovie', out.P.win, movieFile)
% end

%% fixation -- 1 sec -- (100 frame @100Hz)

Screen('FillRect',out.P.win, out.P.grey);
cr.vbl = Screen('Flip',out.P.win);
do_trigger(out, 1)

base = GetSecs();
for frameL = out.P.frames.fix
    
    Screen('FrameArc', out.P.win, [0 0 0], out.P.rect_cue, 0, 360, 4,4);
    cr.vbl = Screen('Flip',out.P.win, cr.vbl+.5*out.P.ifi);

% movie
%     if cr.lLoop==1
%         Screen('AddFrameToMovie',out.P.win);
%     end
     
end
tFix = GetSecs()-base;
out.blocks(out.blockcount).timestamp(out.trlcount, 1) = tFix;
%out.P.image_fix{cr.lLoop} = Screen('GetImage',out.P.win);


%% array -- 500 msec -- (50 frames @100 Hz) + beep

% Screen('FillRect',out.P.win, [128 128 128])
% cr.vbl = Screen('Flip',out.P.win, cr.vbl+.5*out.P.ifi);

base = GetSecs();
for frameL = out.P.frames.squares
    

    Screen('FrameArc', out.P.win, [0 0 0], out.P.rect_cue, 0, 360, 4,4);
    Screen('FillRect', out.P.win, cr.which_cols1, out.P.square_pos);
    
    if frameL == out.P.frames.squares(end-1)
        PsychPortAudio('Start', out.P.pahandle, out.P.repetition, 0, 1);
        % don't wait for sound to end 
%         [out.P.actualStartTime, ~, ~, out.P.estStopTime] = ...
%             PsychPortAudio('Stop', out.P.pahandle, 0, 0);

    elseif frameL ==1
        
        do_trigger(out, 100)
        
    end
    
    cr.vbl = Screen('Flip',out.P.win, cr.vbl+.5*out.P.ifi);
    
        
        
%     if cr.lLoop==1
%         Screen('AddFrameToMovie',out.P.win);
%     end
    
end
tArray = GetSecs()-base;
out.blocks(out.blockcount).timestamp(out.trlcount, 1) = tArray;
%out.P.image_array{cr.lLoop} = Screen('GetImage',out.P.win);


%% GAP -- delta t  -- waiting for flash

base = GetSecs();
for frameL = out.P.frames.IsquareInt
    
    % draw grey screen
    Screen('FillRect',out.P.win, out.P.grey);
    
    Screen('FrameArc', out.P.win, [0 0 0], out.P.rect_cue, 0, 360, 4,4)
    cr.vbl = Screen('Flip',out.P.win, cr.vbl+.5*out.P.ifi);
    
    if frameL == 1
        
        do_trigger(out, 99)
        
    end

    
    % fixation control
    if out.eyelinkconnected
        [~,~,hsmvd] = EyelinkGetGaze(out.E, out.E.gcntrl.ignblnk, ...
            out.E.gcntrl.ovrsmplbvr);
    else
        hsmvd = KbCheck; % debug purpose
    end
    
    if hsmvd
        out = do_fixcontrol(out);
        return
    end

    
%     if cr.lLoop==1
%         Screen('AddFrameToMovie',out.P.win);
%     end
    
end
tGap = GetSecs()-base;
out.blocks(out.blockcount).timestamp(out.trlcount, 3) = tGap;


%% TEST ARRAY -- until response --

base = GetSecs();
acc = 0;
while waitResponse==false
    
%     %debug square cuing
%     msg_debug = ['load ' num2str(out.P.condLoad(cr.lLoop)) 'cue '...
%         num2str(out.P.square_change(cr.lLoop,:))];
%     
%     DrawFormattedText(out.P.win,msg_debug,...
%         out.P.xCenter+600, out.P.yCenter-400, out.P.black);
    
    
    Screen('FillRect', out.P.win, cr.which_cols2, out.P.square_pos);
    Screen('FrameArc', out.P.win, [0 0 0], out.P.rect_cue, 0, 360, 4,4);
    % dx cue response
    DrawFormattedText(out.P.win, '"M" se uguale', out.P.xCenter+400, ...
        out.P.yCenter+350, out.P.black);
    % sx cue response
    DrawFormattedText(out.P.win, '"Z" se diverso', out.P.xCenter-610, ...
        out.P.yCenter+350, out.P.black);
    
    cr.vbl = Screen('Flip', out.P.win, cr.vbl+.5*out.P.ifi);
    
    acc = acc+1;
    
    if acc == 1
        
        do_trigger(out, 200+ischanging)
        
    end

%     if cr.lLoop==1
%         Screen('AddFrameToMovie',out.P.win);
%     end
    
    [keyDown, ~, keyCode]=KbCheck;

    if keyDown==1
        code=find(keyCode);
        if code ==out.P.escapeKey
             waitResponse=true;
             out = do_abort(out);

        elseif code==out.P.zKey
            out.blocks(out.blockcount).data(out.trlcount,5)=1; % z -> different = 1 |||| CHANGE DETECTION!!!!!!
            waitResponse=true;
            
            do_trigger(out, 301)

        elseif code==out.P.mKey
            out.blocks(out.blockcount).data(out.trlcount,5)=0; % m -> equal = 0
            waitResponse=true;

            do_trigger(out, 300)
            
        end
        
    end

end
tResp = GetSecs()-base;
out.blocks(out.blockcount).timestamp(out.trlcount, 6) = tResp;
%out.P.image_test{cr.lLoop} = Screen('GetImage',out.P.win);

%% only in case of practice -1-
% provide feedback

if isfield(out, 'FLAGpractice')
    
    if out.FLAGpractice

        iscorrect = out.blocks(out.blockcount).data(out.trlcount,5)==...
            ischanging;
        
        Screen('FillRect',out.P.win, out.P.grey);

        if iscorrect
            
            % correct feedback
            Screen('TextSize', out.P.win, 35);
            Screen('TextFont', out.P.win, 'Tahoma');
            DrawFormattedText(out.P.win, 'Corretto! :)',...
                'center', 'center', [0 255 0]);
            
        else
            
            % correct feedback
            Screen('TextSize', out.P.win, 35);
            Screen('TextFont', out.P.win, 'Tahoma');
            DrawFormattedText(out.P.win, 'Sbagliato... :|',...
                'center', 'center', [255 0 0]);

        end
        
        cr.vbl = Screen('Flip', out.P.win, cr.vbl+.5*out.P.ifi);

    end
    
    WaitSecs(.7)
    
end


 
end    
