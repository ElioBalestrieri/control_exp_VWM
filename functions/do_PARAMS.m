function in = do_PARAMS(in)
% define common parameters for all modules, and specific parameters for
% each of them


%% common

P.FLAG.debug = true;

if P.FLAG.debug
    warning('script executed in debug mode')
end

%% start ptb

P = local_init_ptb(P);

% subject distance from screen (mm)
P.dist_subj = 600;

convert = pi/180; % 1° -> conversion degree to radians
visAngle2pixels = @(deg, main) round((tan(deg*convert/2)*2*main.dist_subj)/...  V = 2*arctan(S/2D) --> V/2 = arctan(S/2D) --> tan(V/2) = S/2D --> 
    main.size_1px_mm);% ##CHECK                                                    S = tan(V/2)*2D [D observer distance; V vis angle; S segment length]


%% define visual features of the experiment 
% most of them are defined as radius (easier to handle to the center of the
% screen); 

% define contrast as input from GUI
P.cntFLASHthres = 1;

% radius of cue 
P.radius_cue = round(visAngle2pixels(4,P)/2); %###################### 2° of radius --> circle has diameter 4 vis angles    

% radiuses of squares (external and internal vertices)
P.radius_squares = [visAngle2pixels(6,P)...
    visAngle2pixels(2,P)];%*sin(pi/4); %################################ each square has a side of 4�

% radius of flash target
P.radiusFLASH = round(visAngle2pixels(.5,P)/2);

% radius of randomization of target appearence
P.yxFLASHnoise = [round(visAngle2pixels(2,P)/2),...
    round(visAngle2pixels(2,P)/2)];%### define diameter of 2° of possible appearance of flash

% define square surrounding circle cue to select patch
P.rect_cue = [P.xCenter-P.radius_cue, P.yCenter-P.radius_cue,...
    P.xCenter+P.radius_cue, P.yCenter+P.radius_cue];

% define squares positions
P.square_pos = [P.xCenter-max(P.radius_squares),...1 square   
                   P.xCenter-max(P.radius_squares),...
                   P.xCenter+min(P.radius_squares),...
                   P.xCenter+min(P.radius_squares);...
                   P.yCenter-max(P.radius_squares),...1 square
                   P.yCenter+min(P.radius_squares),...
                   P.yCenter+min(P.radius_squares),...
                   P.yCenter-max(P.radius_squares);...4 square --> end first point
                   P.xCenter-min(P.radius_squares),...
                   P.xCenter-min(P.radius_squares),...
                   P.xCenter+max(P.radius_squares),...
                   P.xCenter+max(P.radius_squares);...
                   P.yCenter-min(P.radius_squares),...
                   P.yCenter+max(P.radius_squares),...
                   P.yCenter+max(P.radius_squares),...
                   P.yCenter-min(P.radius_squares)];


%######################## manually chosen colours #########################
% testing colors -- https://www.colorspire.com/rgb-color-wheel/
% keeping stable "v" value --luminance-- while manually choose the hue

P.colormap = [198, 0, 0;...      red
                191, 0, 198;...     purple
                0, 0, 198; ...      blue
                0, 191, 198; ...    light blue
                33, 198, 0; ...     green
                191, 198, 0];%      yellowish
            
% background color .5
P.baseluminance = .5;

%% current trl parameters
P.frames.fix = 1:100;
P.frames.squares = 1:49;     % set to 49 frames instead of 50 to take into account stable delay of starting reset sound
P.frames.delta = []; 
P.frames.flash = 1;          % default MUST = 1
P.frames.IsquareInt = 1:100;

if P.frames.flash ~= 1
    error('flash should last one frame')
end

%% create subfields preallocate conditions balanced in the block

P.cond.flashVScatch =[0 1];  % flash present vs absent, 2 conditions 
P.cond.vwm_eqVSdiff =[0 1];  % equal vs different, 2 conditions
P.cond.deltaT = (0:4:60)+15; % take a vector of 16 steps, [0 to 60 frames]--with step 4--(10 msXframe) and sum baseline frames

%% preallocate conditions
switch in.which_module
    
    case 'EXP'
        P.nblocks = in.macro.endblck - in.macro.strtblck + 1;
        P.ntrlsblock = 160;
        for iB = 1:P.nblocks
            P.B(iB).which_cond = local_preallocate_mainEXP(P);            
        end
        
    case 'VWM'
        P.nblocks = 1;
        P.ntrlsblock = 80;
        P.B.which_cond = local_preallocate_VWM(P);
        
    case 'QUEST'
        P.nblocks = 1;
        P.ntrlsblock = 50;
        P = local_prepare_QUEST(P);

end

%% preallocate data matrices
% columns as follows:
% 1- SOA, 2-flash present (1) or absent (0), 3- square same (1) or
% different (0), 4- subj resp for flash (as before), 5- subj resp for
% memory (as before).

% do the same for timestamps:
% 1- fixation, 2- square array, 3- SOA, 4- flash, 5- t-SOA, 6- RT square,
% 7- RT flash

for iB = 1:P.nblocks
    in.blocks(iB).data = nan(P.ntrlsblock, 5);    
    in.blocks(iB).timestamp = nan(P.ntrlsblock, 7);
    
end

%% back assign parameter structure
in.P = P;

end

%% ####################### LOCAL FUNCTIONS ###############################

function P = local_init_ptb(P)

%% call ptb parameters --> insert in new window afterward

KbName('UnifyKeyNames'); %enables cross-platform key iqd's

P.displayScreen = max(Screen('Screens'));
rect0 = [0 0 1920 750]; % debug purpose
[P.win,P.rect] = Screen('OpenWindow',P.displayScreen,[128 128 128]); %, rect0);
% Retreive the maximum priority number
[P.xCenter,P.yCenter] = RectCenter(P.rect);
P.ifi = Screen('GetFlipInterval', P.win);


%% check for ifi ########################################################## UNCOMMENT IN PC
if round(1/P.ifi)~=100
    if ~ P.FLAG.debug
        error('detected wrong refresh rate')
    end
end

P.black = BlackIndex(P.displayScreen);
P.white = WhiteIndex(P.displayScreen);
P.grey = round(P.white/2);
P.redfix = round([0.6 0 0]*255);
P.greenfix = round([0 0.6 0]*255);

P.srStrct = Screen('Resolution', P.displayScreen);
P.pxlScreen = [P.srStrct.width, P.srStrct.height];
% manual measurements of screen dimension, since
% " Screen('DisplaySize',main.displayScreen); "  was inaccurate [????]
P.m_width = 520;
P.m_height = 294;    

P.size_mm_screen = [P.m_width, P.m_height];
P.size_1px_wid_heig = P.size_mm_screen./P.pxlScreen; % scale ~equal for each dimension: take average
P.size_1px_mm = mean(P.size_1px_wid_heig); % 

% initialize sounDriver
P.beepDuration = 2*P.ifi; % ! this means the new beep is going to be 10 ms
InitializePsychSound(1);
P.sampleBeep = 48000;
P.nrchannels = 2; % don't change or it'll stop audio driver?!
P.repetition = 1;
xBeep = 0:1/P.sampleBeep:P.beepDuration-1/P.sampleBeep;
P.resetBeep = sin(500*xBeep*2*pi); % actual "beep": a sinusoid at 500 Hz
% wait for device to start (1=yes)
P.waitDev = 1;
% open PsychAudio port
% P.pahandle = PsychPortAudio('Open', [], 1, 1, P.sampleBeep,...
%     P.nrchannels);
% 
% % Set the volume to one
% PsychPortAudio('Volume', P.pahandle, 1);
% 
% % Fill the audio playback buffer with the audio data, doubled for stereo
% % presentation
% PsychPortAudio('FillBuffer', P.pahandle, [P.resetBeep;...
%     P.resetBeep]);

% set keyboard responses
P.zKey = KbName('z');
P.mKey = KbName('m');
P.yKey = KbName('y');
P.nKey = KbName('n');
P.oKey = KbName('o');
P.lKey = KbName('l');
P.iKey = KbName('i');
P.kKey = KbName('k');
P.escapeKey = KbName('ESCAPE');

% hide cursor
HideCursor(P.displayScreen);


end

function which_cond = local_preallocate_mainEXP(P)
%% preallocate conditions:
% equality vs difference in VWM, flash vs catch, SOA
% create a balanced matrix, and repeat the occurrences
red_mat = CombVec(P.cond.vwm_eqVSdiff, P.cond.flashVScatch, P.cond.deltaT)'; 
f_present = red_mat(red_mat(:,2)==1,:);
f_absent = red_mat(red_mat(:,2)==0,:);

one_block_unshuffled = [repmat(f_present, 4,1); f_absent];

shuffled = nan(size(one_block_unshuffled));

rnd_idx = randsample(length(one_block_unshuffled), length(one_block_unshuffled))';

% shuffle the matrix
acc = 1;
for iIdx = rnd_idx
    
    shuffled(acc, :) = one_block_unshuffled(iIdx,:);
    
end

which_cond = shuffled;

end

function which_cond = local_preallocate_VWM(P)
%%
unshuffled = repmat([0; 1], P.ntrlsblock/2,1);
which_cond = randsample(unshuffled, P.ntrlsblock);

end

function P = local_prepare_QUEST(P)

P.anon.cnt2weber = @(cnt) cnt/(P.baseluminance);
P.anon.weber2cnt = @(web) web*P.baseluminance;

P.Q.tGuess = log10(P.anon.cnt2weber(.1)); 
P.Q.tGuessSD = 3; 
P.Q.setThreshold = .6; 
P.Q.beta = 3.5;
P.Q.lapse_rate = .01;
P.Q.guess_rate = .25;
P.Q.thisQUEST = QuestCreate(P.Q.tGuess, P.Q.tGuessSD, P.Q.setThreshold, ...
    P.Q.beta, P.Q.lapse_rate, P.Q.guess_rate, 1/255, 1.5); %last 2 par used where: , 1/255, 1.5
P.Q.thisQUEST.normalizePdf = 1;

P.vectorPi = [1 3 5 7];
P.yCoorPrompt = round(sin(pi*P.vectorPi/4)*3*P.yxFLASHnoise(1)+P.yCenter);
P.xCoorPrompt = round(cos(pi*P.vectorPi/4)*3*P.yxFLASHnoise(2)+P.xCenter);




end








