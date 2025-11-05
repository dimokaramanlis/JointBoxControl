function runavg = getRunningAverages(Data, beta)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%----------------------------------------------------------------------
Ntrials       = max(Data.TrialNumber);
runavg.isopto = nan(Ntrials, 2);
if isfield(Data, 'isOpto')
    if any(Data.isOpto,"all")
        runavg.isopto = Data.isOpto;
    end
end
%----------------------------------------------------------------------
moldperf   =  [1 1] * 0.5;
moldchoice =  [1 1] * 0.5;
molddiseng =  0;

runavg.perfavg    = NaN(Ntrials, 2, 'single');
runavg.choiceavg  = NaN(Ntrials, 2, 'single');
runavg.disengavg  = NaN(Ntrials, 2, 'single');
runavg.iscongr    = zeros(Ntrials, 1, 'single');

for ii = 1:Ntrials
    %----------------------------------------------------------------------
    runavg.iscongr(ii) = Data.TrialSettings(ii).GUI.Dependent;
    mcurr              = Data.TrialOutcome(ii, :);
    chcurr             = Data.MouseChoice(ii, :);
    trialtype          = Data.TrialTypes(ii, :);
    %----------------------------------------------------------------------
    % disengagement
    dcurr            = isnan(chcurr) & ~isnan(trialtype);
    molddiseng       = beta * molddiseng + (1 - beta) * dcurr;
    runavg.disengavg(ii, :) = molddiseng;
    %----------------------------------------------------------------------
    % abort invalid trials
    if any(mcurr<0), continue,  end
    % regress to 0.5 when task setting changes...
    if ~isequal(isnan(mcurr), isnan(moldperf))
        moldperf = ~isnan(mcurr) * 0.5;
    end
    moldperf    = beta * moldperf + (1 - beta) * mcurr;
    runavg.perfavg(ii, :) = moldperf;

    
    % abort invalid trials
    if all(isnan(chcurr)), continue,  end
    chcurr = (chcurr+1)/2;
    % regress to 0.5 when task setting changes...
    if ~isequal(isnan(chcurr), isnan(moldchoice))
        moldchoice = ~isnan(chcurr) * 0.5;
    end
    moldchoice    = beta * moldchoice + (1 - beta) * chcurr;
    runavg.choiceavg(ii, :) = moldchoice;
end


end