function out = do_trial_QUEST(out)

% determine contrast for the present trial
cur_web = 10^QuestQuantile(out.P.Q.thisQUEST);
cur_lum = out.P.anon.weber2cnt(cur_web);

% .. and correct potential negative values due to initial QUEST's huge
% jumps
if sign(cur_lum)~=1 
    cur_lum=1/255;            
end

% determine position of flash appearance
posQuad = randsample(out.P.vectorPi,1);

% let's start saving data. data has 5 columns, so this is the displacement:
% col 1 -> weber contrast; col 2 -> normalized 01 luminance with respect to
% the background; col 3 -> target pos; col 4 -> subj resp; col 5 -> resp
% correct

out.blocks.data(out.trlcount,1) = cur_web;
out.blocks.data(out.trlcount,2) = cur_lum;
out.blocks.data(out.trlcount,3) = posQuad;

% determine spatial position of flash on screen and draw the corresponding
% texture

corrPosQuad = round([-sin(posQuad*pi/4)*out.P.yxFLASHnoise(1),...
    cos(posQuad*pi/4)*out.P.yxFLASHnoise(2)]);

[swapMat1, cntX1, cntY1] = ...
    drawFlash4pos_gaussian(out.P.srStrct.width,out.P.srStrct.height,...
    cur_lum,out.P.radiusFLASH, out.P.grey/255,2000,corrPosQuad);

squareFLASH1 = [cntX1-out.P.radiusFLASH, cntY1-out.P.radiusFLASH,...
            cntX1+out.P.radiusFLASH, cntY1+out.P.radiusFLASH];

indxMat= Screen('MakeTexture', out.P.win, uint8(swapMat1*255));
        
% determine temporal onset of flash
tPoint = rand*.6;  
totifis = numel(0:out.P.ifi:1);
nifisPRE = numel(0:out.P.ifi:tPoint);
nifisPOST = totifis-nifisPRE; nifisPRE = nifisPRE-1; % to account flash appearance

%% start trial
% Color the screen grey
Screen('FillRect', out.P.win, out.P.grey);
Screen('Flip', out.P.win);
WaitSecs(.2);

% red Fixation Marker
DrawFixationMarker(out.P.win,out.P.xCenter,...
    out.P.yCenter,out.P.redfix, out.P.grey);
Screen('Flip',  out.P.win);

% let the subject start the trial
KbStrokeWait;

% green Fixation Marker
DrawFixationMarker(out.P.win,out.P.xCenter,...
    out.P.yCenter,out.P.greenfix, out.P.grey);

Screen('Flip', out.P.win);

WaitSecs(.5);

% Color the screen grey
Screen('FillRect', out.P.win, out.P.grey);
vbl = Screen('Flip', out.P.win);
WaitSecs(.15);

%% pre stim 
bslTRL = GetSecs;
for frameGo=1:nifisPRE
    
    % Color the screen grey
    Screen('FillRect', out.P.win, out.P.grey);
    % Flip to the screen
    vbl = Screen('Flip', out.P.win, vbl+.5*out.P.ifi);
    
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


end
out.blocks.timestamp(out.trlcount, 1) = GetSecs-bslTRL;

%% stim 
bslTRL = GetSecs;
for frameGo = out.P.frames.flash
    
    Screen('DrawTexture', out.P.win,  indxMat,  squareFLASH1,...
        squareFLASH1);
    % Flip to the screen
    vbl = Screen('Flip',  out.P.win, vbl+.5*out.P.ifi);

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

    
end
out.blocks.timestamp(out.trlcount, 2) = GetSecs-bslTRL;

%% post stim 
bslTRL = GetSecs;
for frameGo=1:nifisPOST
    
    % Color the screen grey
    Screen('FillRect', out.P.win, out.P.grey);
    % Flip to the screen
    vbl = Screen('Flip', out.P.win, vbl+.5*out.P.ifi);
    
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


end
out.blocks.timestamp(out.trlcount, 3) = GetSecs-bslTRL;

%% prompt response
% prompt response 
Screen('TextSize',  out.P.win, 30);
% Screen('TextFont',  window, 'Tahoma');
DrawFormattedText( out.P.win, 'O',out.P.xCoorPrompt(1), out.P.yCoorPrompt(4), out.P.black);
DrawFormattedText( out.P.win, 'I',out.P.xCoorPrompt(2), out.P.yCoorPrompt(3),  out.P.black);
DrawFormattedText( out.P.win, 'K',out.P.xCoorPrompt(3), out.P.yCoorPrompt(2),  out.P.black);
DrawFormattedText( out.P.win, 'L',out.P.xCoorPrompt(4), out.P.yCoorPrompt(1),  out.P.black);
Screen('DrawLine', out.P.win, out.P.black, out.P.xCenter,out.P.yCoorPrompt(2),...
    out.P.xCenter,out.P.yCoorPrompt(3));
Screen('DrawLine', out.P.win, out.P.black, out.P.xCoorPrompt(3), out.P.yCenter,...
    out.P.xCoorPrompt(4), out.P.yCenter);

Screen('Flip',  out.P.win);

%% wait for response
isrightbuttonpress = false;
bslTRL = GetSecs;
while ~isrightbuttonpress
    
    [~, t, code, ~] = KbCheck;

    keycode=find(code);
    if keycode == out.P.escapeKey
        out = do_abort(out);
        isrightbuttonpress = true;
        subjresp = 666;
    elseif keycode== out.P.oKey
        subjresp=1;
        isrightbuttonpress = true;
    elseif keycode== out.P.lKey
        subjresp=7;
        isrightbuttonpress = true;
    elseif keycode== out.P.kKey
        subjresp=5;
        isrightbuttonpress = true;
    elseif keycode== out.P.iKey
        subjresp=3;
        isrightbuttonpress = true;
    end

    if isrightbuttonpress
        rt = t-bslTRL;
    end
end

%% determine correctness of resp
isrespcorrect = subjresp==posQuad;
%... and save all the info in the logfiles
out.blocks.data(out.trlcount,4) = subjresp;
out.blocks.data(out.trlcount,5) = isrespcorrect;
out.blocks.timestamp(out.trlcount,4) = rt;


if isfield(out, 'FLAGpractice')
    
    if out.FLAGpractice
        
        Screen('FillRect',out.P.win, out.P.grey)

        if isrespcorrect
            
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
        
        Screen('Flip', out.P.win);

    end
    
    WaitSecs(.7)
    
end



%% update QUEST based on the current response
if ~isfield(out, 'FLAGpractice')
    out.P.Q.thisQUEST = QuestUpdate(out.P.Q.thisQUEST,log10(cur_web),isrespcorrect);
end

Screen('Close', indxMat);


end