function [out] = do_PARAMS_ET(out)
% creates P.ET, a substructure with fields readable by Wanja's function EyelinkStart
P = out.P;
%% definition of eyelink-specific substructure

out.E.myWidth = P.pxlScreen(1);
out.E.myHeight = P.pxlScreen(2);
out.E.BgColor = P.grey;
out.E.EDFdir = out.macro.data_path;
out.E.gui = 0;

% default for binocular tracking
out.E.binocular = true;
out.E.eyelink_conf_table = 'BTABLER';
out.E.sampling_rate = 500;

% here put other parameters for gaze control function called during the
% experiment, like the confidence area etc
out.E.gcntrl.ignblnk = 0;
out.E.gcntrl.ovrsmplbvr = 0; 
out.E.CenterX = P.xCenter;
out.E.CenterY = P.yCenter;
out.E.FixLenDeg = 2; % P.radius_cue;
out.E.pixperdeg = P.pixperdeg;



end

