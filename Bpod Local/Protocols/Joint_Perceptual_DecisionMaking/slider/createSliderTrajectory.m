function SliderProperties = createSliderTrajectory(S, SliderProperties, currreward, mousesetting)
%CREATEANDDRAWTEXTURES Takes the current trial types and creates the
%appropriate textures on the screen.

%-----------------------------------------------------------------------------------------------------------------
% some checks
dtmin         = max(S.GUI.DTimeMin, 1e-3);
dtmax         = max(dtmin + 1e-3, S.GUI.DTimeMax);
sliderDecTime = dtmin + rand(1) * (dtmax - dtmin);

SliderProperties.dectime = sliderDecTime;
%-----------------------------------------------------------------------------------------------------------------
% performance always between 0 and 1
perfcurr      = min(S.GUI.Performance, 1);
perfcurr      = max(perfcurr, 0);
slideroutcome = rand(1) < perfcurr;
SliderProperties.outcome = slideroutcome;
%-----------------------------------------------------------------------------------------------------------------
rewlicktime = max(S.GUI.RewardStayTime, 1e-3);
SliderProperties.rewstay = rewlicktime;
%-----------------------------------------------------------------------------------------------------------------
maxspeed = max(S.GUI.MaxSpeed, 0);
maxspeed = min(maxspeed, 85); % WE CAN INCREASE THIS IF WE TEST!!!!!!!!!!
SliderProperties.maxspeed = maxspeed;
%-----------------------------------------------------------------------------------------------------------------
rewside = currreward;
if mousesetting == 1
    rewside = -currreward;
end
if slideroutcome == 0
    rewside = -rewside;
end
SliderProperties.rewside = rewside;
%-----------------------------------------------------------------------------------------------------------------
% TODO
% Here we create a trajectory that will be initiated by the state machine
% the trajectory will wait till the robo is available and then start
% roaming


%-----------------------------------------------------------------------------------------------------------------
end
