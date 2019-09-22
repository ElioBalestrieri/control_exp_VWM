function out = do_trial_QUEST(out)

foo = 1;

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



end