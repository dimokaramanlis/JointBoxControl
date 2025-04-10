function sliderProperties = createSliderTrajectory(S, sliderProperties, currreward, sliderside)
%CREATEANDDRAWTEXTURES Takes the current trial types and creates the
%appropriate textures on the screen.

%-----------------------------------------------------------------------------------------------------------------
% performance always between 0 and 1
perfcurr      = min(S.GUI.Performance, 1);
perfcurr      = max(perfcurr, 0);
slideroutcome = rand(1) < perfcurr;
sliderProperties.outcome = slideroutcome;
%-----------------------------------------------------------------------------------------------------------------
% some checks
dtmin         = max(S.GUI.DTimeMin, 1e-3);
dtmax         = max(dtmin + 1e-3, S.GUI.DTimeMax);
gmean         = dtmin +  (dtmax - dtmin)/2;
gsigma        = (dtmax - dtmin)/3;
if slideroutcome == 1
    gsigma = gsigma/2;
end
sliderDecTime = gmean + randn(1) * gsigma;
sliderDecTime = max(sliderDecTime, 1e-3);

sliderProperties.dectime = sliderDecTime;
%-----------------------------------------------------------------------------------------------------------------
rewlicktime = max(S.GUI.RewardStayTime, 1e-3);
sliderProperties.rewstay = rewlicktime;
%-----------------------------------------------------------------------------------------------------------------
maxspeed = max(S.GUI.MaxSpeed, 0);
maxspeed = min(maxspeed, 100); % WE CAN INCREASE THIS IF WE TEST!!!!!!!!!!
sliderProperties.maxspeed = maxspeed;
%-----------------------------------------------------------------------------------------------------------------
sliderchoice = currreward(sliderside);
if sliderside == 2
    sliderchoice = -currreward;
end
if slideroutcome == 0
    sliderchoice = -sliderchoice;
end
sliderProperties.sliderchoice = sliderchoice;
%-----------------------------------------------------------------------------------------------------------------
sliderProperties.UncertaintySD = S.GUI.UncertaintySD;
%-----------------------------------------------------------------------------------------------------------------
% TODO
% Here we create a trajectory that will be initiated by the state machine
% the trajectory will wait till the robo is available and then start
% roaming
sliderProperties.trajx = 1;
sliderProperties.RoamingType = S.GUI.RoamingType;
sliderProperties.RoamingSD   = sliderProperties.UncertaintySD/3;
%-----------------------------------------------------------------------------------------------------------------
end
