

viewdist = 60; % cm
eyedness = 0; % 0 -> left; 1 -> right
useET = true; % use the eye-tracker or not

matfilename = 'this_data.mat';
eyefilename = 'test.edf';
eyefiledir = 'edf'; % this folder to be created if it does not exist!

diary('logfile.log');

% Screen dimensions --- ALWAYS CHANGE THIS ACCORDINGLY!
% ViewPixx/EEG, Model nr. VPX-VPX-2006A, x = 522 mm, y = 293 mm
% MEG lab projector at 100 cm: x = 521 mm, y = 388 mm (my measurements)
% MEG lab projector at 100 cm: x = 510 mm, y = 380 mm (wiki and default eyelink screen setup)
mmx = 510;
mmy = 380;

% stimulus settings
EccDegrees = 8; % was 8 for previous experiments
StimSizeDegrees = 4; % since the face is cut-out (*.36*2!!!) -> essentially StimSizeDegrees * .36 * 2 = (for 4 deg) -> 2.88 deg face size
FixSizeDegrees = .5;
FixWidDegrees = .1;

OldNewFactor = 0.72;
% a factor used to achieve same stimulus size compared to previous
% experiments.


% buttons
ESCKey = KbName('q');
LeftKey = 2; % 2 -> Yellow; previously was KbName('z');
LeftKeyName = 'yellow';
RightKey = 4; % 4 -> Green; previously was KbName('.>'); % the dot '.' is really named '.>'
RightKeyName = 'green';


% colours -- all grey for this experiment!
CueColour1 = [130 130 130];
CueName1 = 'grey';
CueColour2 = [130 130 130];
CueName2 = 'grey';

% TIMING
ELsamplingrate = 1000;
% all valus in SECONDS!
PlaceholderDuration = 1;
PreviewDuration = .500;

% Gaze detection
SacDetectThreshDeg = .18; % .18; % degrees of visual angle between subsequent samples determines saccade
% works in combination with 'heuristic_filter'
SacEndDistTolFactor = 1.5; % for correct saccade the distance from face center in units of face-cut-out-size, 1 means the size of the face cut-out

% convenience
fixationFailedCountdown = 3;

%% ---------------------- Screen setup ----------------------

% hard-code to MEG lab
screenNumber = 1;

% Setting this preference to 1 suppresses the printout of warnings.
Screen('Preference', 'SkipSyncTests', skipsyncTestInput);
% Screen('Preference', 'SkipSyncTests', 0);
AssertOpenGL;

% just get that, so it gets stored, and could be looked-up later for
% verification purposes.
ScreenResolution = Screen('Resolution', screenNumber);
if ScreenResolution.hz ~= 120
    error('Screen refresh rate should be 120 Hz, but PTB reports %f!', ScreenResolution.hz);
end

[resx, resy] = Screen('WindowSize', screenNumber);

% check conversion for px to mm
cmx = mmx/10;
cmy = mmy/10;
% viewdist = ?
% --> per user input above!
centx = .5*resx;
centy = .5*resy;

CmToPixX = (resx/cmx);
CmToPixY = (resy/cmy);
DegToPixX = ceil(tan(2*pi/360)*(viewdist*CmToPixX));
DegToPixY = ceil(tan(2*pi/360)*(viewdist*CmToPixY));

DegToPixXYavg = mean([DegToPixX, DegToPixY]); % they usually only deviate by 1 pix from each other

[window, screenRect] = Screen('OpenWindow',screenNumber, 0); % buffers actually not needed

% colors, etc.
black = BlackIndex(window);
white = WhiteIndex(window);
backgroundEntry = black; %(white+black)*.5; %check this?
foregroundEntry = white;

feedbackColorCorrect = white;
feedbackColorWrong = [250 20 20]; % a red
feedbackColorInvalid = feedbackColorWrong; % the same

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

HideCursor;
ListenChar(2); % suppress key stroke output to command line

PhdRect = [0 0 30 30];
PhdColor = white;

%% ------------------- calculate stimulus dimensions -------------------

Ecc = EccDegrees * DegToPixX;
StimSize = StimSizeDegrees * DegToPixX;
FixSize = FixSizeDegrees * DegToPixX;
FixWid = FixWidDegrees * DegToPixX;

centxL = centx - Ecc;
centxR = centx + Ecc;

% Fixation cross
FixCrossRect = [[(centx - FixSize/2),(centy - FixWid/2),(centx + FixSize/2), (centy + FixWid/2)]', ...
                [(centx - FixWid/2), (centy - FixSize/2),(centx + FixWid/2),(centy + FixSize/2)]'];
            


%% ------------ SACCADE DETECTION and TIMING ------------------------------

% NOTE: Eye-tracker sampling rate has to be 1000 Hz for these settings to
% work as expected.
if useET && ELsamplingrate ~= 1000
    error('Eye tracker sampling rate has to be 1000 Hz for current saccade detection thresholds!');
end

% saccade detection threshold in pixels
SacDetectThreshPix = SacDetectThreshDeg * DegToPixX;

FlpInt = Screen('GetFlipInterval', window);

% fc_ ... fixate centre (before preview)
fc_time = PlaceholderDuration - FlpInt/2; % secs, time stable gaze required to start a trial
fc_deg = 2;
fc_pixel = fc_deg * DegToPixXYavg; % max pixel deviation from centre gaze for fixation check

% Criteria for correct saccades
% for saccade towards target: saccade landing point tolerance
SacEndDistTolDeg = StimSizeDegrees * OldNewFactor/2 * SacEndDistTolFactor; % distance from target centre, i.e. radius, not diameter!
SacEndDistTolPix = SacEndDistTolDeg * DegToPixXYavg;



%% ------------------ setup EYE-TRACKER ------------------

if useET
    EyelinkInit(0); % 0 -> don't ask for dummymode

    el = EyelinkInitDefaults(window); % works also without initilized eye-tracker
    
    % We are changing calibration to a black background with almost white
    % targets, no sound and smaller targets
    el.backgroundcolour = 0;%BlackIndex(el.expWin);
    el.foregroundcolour = 250; % not completely white % white;
    el.msgfontcolour = 250; %WhiteIndex(el.expWin);
    el.imgtitlecolour = 250; %WhiteIndex(el.expWin);
    el.targetbeep = 0;
    % no sound cause PTB audio not working
    if ~useSound
        % turn off all beeps
        el.feedbackbeep = 0;
        el.calibration_target_beep = 0;
        % Make sure to use only recognised field names, otherwise there is a cryptic
        % error message from Eyelink.c/mex file. The following names have not yet
        % been checked:
%         el.drift_correction_target_beep = 0;
%         el.calibration_failed_beep = 0;
%         el.calibration_success_beep = 0;
%         el.drift_correction_failed_beep = 0;
%         el.drift_correction_success_beep = 0;
    end
    
    el.calibrationtargetcolour = el.foregroundcolour; % has to be same, because of bug in 'EyelinkDrawCalTarget.m'
    % 'width' (inner circle) has to be smaller than 'size' (outer circle),
    % otherwise calibration target has background colour, i.e. it is
    % invisible, see >> open EyelinkDrawCalTarget
    el.calibrationtargetsize = .5;
    el.calibrationtargetwidth = .3; % propertion of "size"
    
    EyelinkUpdateDefaults(el);
    
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.05);
    % Set-up datafile -----------------------------------------------------
    
    Eyelink('Openfile', eyefilename);
    
    Eyelink('command', sprintf('add_file_preamble_text ''Recorded by EyelinkToolbox, Experiment %s, %s, partnr: %02d''', mfilename, dateString, partnr));
    WaitSecs(0.05);
    Eyelink('message', 'partnr %02d', partnr);
    WaitSecs(0.05);
    Eyelink('message', '%s', dateString);
    WaitSecs(0.05);
    
    % Set-up screen res ---------------------------------------------------
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, resx-1, resy-1);
    % ... continued below!
    
    % Set calibration type ------------------------------------------------
    Eyelink('command', 'calibration_type = HV9'); % use 9-point, since that's recommended for the long range setup as it is in the MEG lab (says Davide)
    % manually specify location of calibration targets
    Eyelink('command', 'generate_default_targets = NO');
    % for 9-point calibration
    % 5 1 6
    % 3 0 4
    % 7 2 8
    Eyelink('command', 'calibration_targets = %ld,%ld  %ld,%ld  %ld,%ld  %ld,%ld  %ld,%ld %ld,%ld  %ld,%ld  %ld,%ld  %ld,%ld', ...
        resx/2,resy/2, resx/2,resy/4, resx/2,resy*3/4 , resx/4,resy/2 , resx*3/4,resy/2, resx/4,resy/4, resx*3/4,resy/4, resx/4,resy*3/4, resx*3/4,resy*3/4);
    Eyelink('command', 'validation_targets = %ld,%ld  %ld,%ld  %ld,%ld  %ld,%ld  %ld,%ld %ld,%ld  %ld,%ld  %ld,%ld  %ld,%ld', ...
        resx/2,resy/2, resx/2,resy/4, resx/2,resy*3/4 , resx/4,resy/2 , resx*3/4,resy/2, resx/4,resy/4, resx*3/4,resy/4, resx/4,resy*3/4, resx*3/4,resy*3/4);
    % Example for a 1024 x 768 screen:
    %Eyelink('command', 'validation_targets = 512,384  512,192  512,576  256,384  768,384  256,192  768,192  256,576  768,576');
    
    % has to be executed after calibration targets were specified:
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, resx-1, resy-1);
    
    % only do monocular recording
    Eyelink('command', 'binocular_enabled = NO'); WaitSecs(0.05); % see Eyelink Programmers Guide
    % Eyelink('command', 'binocular_enabled = YES'); WaitSecs(0.05); % see Eyelink Programmers Guide
    % -> set to binocular since this is the MEG lab's default
    % we want pupil area, not diameter
    Eyelink('command', 'pupil_size_diameter = NO'); WaitSecs(0.05);
    
    % Set sampling rate ---------------------------------------------------
    % set above.
    Eyelink('command', 'sample_rate = %d', ELsamplingrate); WaitSecs(0.05);
    
    % Set movement thresholds (conservative) ------------------------------
    Eyelink('command', 'saccade_velocity_threshold = 35'); WaitSecs(0.05);
    Eyelink('command', 'saccade_acceleration_threshold = 9500'); WaitSecs(0.05);
    
    % Get tracker and software versions -----------------------------------
    [v,vs] = Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
    % Link to edf data ----------------------------------------------------
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    WaitSecs(0.05);
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT,HTARGET');
    WaitSecs(0.05);
    
    % Link data to Matlab -------------------------------------------------
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
    WaitSecs(0.05);
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT,HTARGET');
    WaitSecs(0.05);
    Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
    WaitSecs(0.05);
    
    % --- which data to send directly to MEG via analog card?
    Eyelink('Command', 'analog_out_data_type = GAZE'); WaitSecs(0.05);
    
    Eyelink('command', 'heuristic_filter = %d', 2); WaitSecs(0.05);
    % useful with respect to online gaze-detection, see settings above
    % It is sufficient to set heuristic_filter only once. The statement in the
    % documentation that it has to be reset every trial is an error in the
    % documentation, see sr supports's response to my post in sr-support forum.
    
    Eyelink('command', 'set_idle_mode'); WaitSecs(0.05);
    
else
    el.f1 = 112;
end




%% ------------ Start the experiment -------------------

EyelinkEnterSetup(el);

%% ------------ Start the trial loop -------------------

% The sequence of textures
% TexPreview - TexCue - TexTransient - TexTarget


NTrials = 10;

graceful_abort = false;
TrialNum = 1; % count trials
blktrl = 1; % trial within block
BlockNum = 1; % count blocks

while TrialNum <= NTrials
    

    % for fixation control during PLACEHOLDER
    fc_success = 0;
    fc_start_time = nan; % gets a value below
    fc_keyisdown = 0;
    fc_secs = nan; % initialize although not needed, since that might speed-up the code
    fc_keycode = nan;
    fc_endPTBtime = nan;
    
    % for saccade onset (end fixation) detection
    sacSamplesX = nan(1,1000); % saccade of 1000 samples is too long anyway
    sacSamplesY = nan(1,1000);
    sacCrit = nan(1,1000);
    % EyeTracked = Eyelink('EyeAvailable') + 1; % --> 1: left, 2: right; see el.RIGHT_EYE, el.LEFT_EYE
    EyeChecked = eyedness + 1; % --> 1: left, 2: right
    % -> 'EyeChecked' could change depending on Eyelink('EyeAvailable')
    % below

    % for sacccade ok?
    SacDirOk = nan;
    SacAmplOk = nan;
    SacEndOk = nan;
    

    %% -------- start recording data --------
    % Start recording at this point to get trigger codes into edf samples
    % for sure
    if useET
        Eyelink('StartRecording'); % adding ", 1, 1, 0, 1);" is not really faster
        % "Linking samples" can be avoided, but it is not really faster without
        % linking samples.
        WaitSecs(0.050);
    end
    
    
    EyeTracked = Eyelink('EyeAvailable');
    % 'EyeAvailable' returns 0 (LEFT_EYE), 1 (RIGHT_EYE) or 2 (BINOCULAR),
    % or -1 of none available
    switch EyeTracked
        % -------
        % EyeChecked be either 1 (left) or 2 (right)!
        % -------
        case 0
            EyeChecked = EyeTracked + 1;
        case 1
            EyeChecked = EyeTracked + 1;
        case 2
            % binocular, thus we take the dominant eye specified in
            % 'eyedness' in the beginning
            EyeChecked = eyedness + 1;
    end

    
    %% prepare and show PLACEHOLDERS
    % Background
    Screen(window,'FillRect', backgroundEntry); % is black anyway, so for photodiode we have to change a part to white
    % Fixation cross
    Screen(window, 'FillRect', white, FixCrossRect);
    % placeholders
    Screen(window, 'FrameOval', white, [(centx - Ecc - (StimSize*OldNewFactor/2)), (centy - (StimSize*OldNewFactor/2)), (centx - Ecc + (StimSize*OldNewFactor/2)), (centy + (StimSize*OldNewFactor/2))]);
    
    [PlaceOnsetVBL, PlaceOnsetTime] = Screen('Flip', window, []);
    if useET, Eyelink('Message', 'TRIGGER %d', 1); end
    
    %% prepare next screen and monitor gaze
    
    % Background
    Screen(window,'FillRect', backgroundEntry);
    % Fixation cross
    Screen(window, 'FillRect', white, FixCrossRect);
    % placeholder circles in a different color
    Screen('FrameOval', window, white, [(centx - Ecc - (StimSize*OldNewFactor/2)), (centy - (StimSize*OldNewFactor/2)), (centx - Ecc + (StimSize*OldNewFactor/2)), (centy + (StimSize*OldNewFactor/2))]);
    
    % *** or draw something in addition in the screen buffer here! ***
    % Screen('Flip', ...) is called after gaze check.
    
    % ensure stable gaze for certain time
    fc_start_time = GetSecs();
    if useET
        while 1
            % THIS Procedure misses really long enduring blinks, but such
            % blinks are very very rare (and they are visible from online
            % inspection of the data on the eye-tracker screen).
            NextDataType = Eyelink('GetNextDataType'); % takes 0.1 ms [sic] to call that function (tested separately).
            if NextDataType >= 3 && NextDataType <= 8 % some eye event (el.FIXUPDATE event, which is 9, excluded)
                fc_start_time = GetSecs(); % restart timer
            elseif NextDataType == 9 % el.FIXUPDATE, usually comes every 50 ms!
                FixUpItem = Eyelink('GetFloatData', NextDataType);
                % check distance from screen center
                if sqrt( (FixUpItem.gavx - centx).^2 + (FixUpItem.gavy - centy).^2 ) > fc_pixel
                    % too far away
                    fc_start_time = GetSecs(); % restart time
                end
            end
            if GetSecs() > fc_start_time + fc_time
                fc_success = 1; % waited long enough without timer reset.
                fc_endPTBtime = GetSecs();
                break
            end
            [fc_keyisdown, fc_secs, fc_keycode] = KbCheck();
            if fc_keyisdown % abort loop by button press
                % if a key was pressed, the timing does NOT matter
                % anymore... since trial will not continue anyway
                if any(find(fc_keycode) == ESCKey)
                    error('Experiment aborted during PLACEHOLDER presentation.');
                elseif any(find(fc_keycode) == el.f1) % graceful abort
                    warning('Experiment aborted by pressing F1!');
                    graceful_abort = true;
                    break
                elseif any(find(fc_keycode) == el.f10) % enter setup and continue with next trials, see below
                    break
                else
                    continue % waiting for gaze ok.
                end
            end
        end % while 1
    else % if no eye-tracker wait for key press
        [fc_secs, fc_keycode] = KbWait([], 2); % KbWait does _not_ return 'keyisdown'
        fc_keyisdown = 1;
        fc_success = 1;
        fc_endPTBtime = GetSecs();
        if any(find(fc_keycode) == el.f1)
            warning('Experiment aborted by pressing F1!');
            graceful_abort = true;
            break
        end
    end
    if fc_success == 0 % recalibrate and restart the trial
        Eyelink('StopRecording');
        WaitSecs(0.50);
        EyelinkEnterSetup(el);
        for countdownSecs = fixationFailedCountdown:-1:1
            Screen(window,'FillRect', backgroundEntry); % clear prepared stuff
            DrawFormattedText(window, ...
                sprintf('The experiment continues in %d seconds...', countdownSecs), ...
                'center', 'center', foregroundEntry,[],[],[],TextvSpacing);
            Screen('Flip', window);
            WaitSecs(.950);
        end
        Screen(window, 'FillRect', backgroundEntry);
        WaitSecs(0.050);
        continue
    end
    
    %% success, so show next screen
    [PreviewOnsetVBL, PreviewOnsetTime] = Screen('Flip', window, []); 
    if useET, Eyelink('Message', 'TRIGGER %d', 2); end

    
    
    %% and continue with other code here
    
    
    % next trial
    TrialNum = TrialNum + 1;
    blktrl = blktrl + 1;
    
end % Trial loop end


%% ----------------------------------------------------------------
%                END OF EYE-TRACKING DATA RECORDING
% -----------------------------------------------------------------

if useET
    Eyelink('command', 'set_idle_mode');
    WaitSecs(0.5);
    Eyelink('closefile');
end

save(matfilename); % save everything up to here.

%% Shut down the Tracker
if useET
    fprintf('Receiving data file ''%s''\n', eyefilename);
    status = Eyelink('ReceiveFile');
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    WaitSecs(1.0); % Give Tracker time to execute all commands
    % move EDF file to subfolder / clean-up
    fprintf('Moving edf file to subfolder ''%s''...\n', eyefiledir);
    try
        [mvEDFsuccess, mvEDFmessage, mvEDFmessID] = movefile(eyefilename, eyefiledir);
        if ~mvEDFsuccess
            warning(mvEDFmessID, mvEDFmessage);
        end
    catch
        fprintf('Failed.\n');
    end
    fprintf('Done.\n');
    Eyelink('Shutdown');
end

%% saving done
if ~isPractice
    endexpttext2 = 'END OF EXPERIMENT. THANK YOU FOR YOUR PARTICIPATION!!!\n\nSaving data... Done.\nPress a button to terminate the program.';
    Screen('FillRect',window,black);
    [nx, ny, bbox] = DrawFormattedText(window, endexpttext2, 'center', 'center', [255 255 255],[],[],[],TextvSpacing);
    Screen(window, 'Flip');
    KbWait([], 2);
end

Screen('CloseAll');
fprintf('Experiment finished %s.\n', datestr(now));
ListenChar(0);
ShowCursor();
diary off;

