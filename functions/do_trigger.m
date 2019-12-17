function do_trigger(out, code)

%% triggers
% trial onset               --> 666
% trial definition          --> SOA (frames)
% 1st square array onscreen --> 100
% squares offscreen         --> 99
% flash                     --> 1000
% second squares onscreen   --> 200 (same) 201 (different)
% subj resp1                --> 300 (same) 301 (different)
% subj resp2                --> 401 (present) 400 (absent)

if ~out.eyelinkconnected
    return
end

if isfield(out, 'FLAGpractice')    
    if out.FLAGpractice
        return
    else
        codestr = num2str(code);
        EyelinkSendTabMsg(codestr);
    end
else
    codestr = num2str(code);
    EyelinkSendTabMsg(codestr);
end


end