function [currStim, currReward] = debugStimReward(S, trialset, oldreward, conhistory, choicehistory)
%DEBUGSTIMREWARD Summary of this function goes here
%   Detailed explanation goes here
%--------------------------------------------------------------------------
torepeat = false; % important for debiasing
if S.GUI.ProbabilityBlue ~=0.5
    randnum    = rand(1);
    currReward = 2 * (randnum > 1 - S.GUI.ProbabilityBlue) - 1;
end

if S.GUI.ProbabilitySetting == 2
    currReward = -oldreward;
end

if S.GUI.ProbabilitySetting == 3
    randnum    = rand(1);
    currReward = 2 * (randnum > 0.5) - 1;
    if size(choicehistory,1)>10
        mousecorrect = choicehistory(end)*conhistory(end);
        torepeat     = mousecorrect<= -0.5;
        if torepeat
            meanuse    = mean(choicehistory(end-9:end, :)==1, 1, 'omitnan');
            valsamp    = randn([1,size(choicehistory,2)])*0.5+meanuse;
            currReward = 2*(valsamp > 0.5)-1;
        end
    end
    
end
%--------------------------------------------------------------------------
if torepeat
    currStim   = abs(conhistory(end)) * currReward;
else
    effset     = find(trialset(:,1)*currReward > 0);
    idran      = randi(numel(effset), 1);
    currStim   = trialset(effset(idran), :);
end
%--------------------------------------------------------------------------

end

