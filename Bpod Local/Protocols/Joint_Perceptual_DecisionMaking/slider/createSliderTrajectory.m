function sliderProperties = createSliderTrajectory(S, sliderProperties, currreward, sliderside)
%CREATEANDDRAWTEXTURES Takes the current trial types and creates the
%appropriate textures on the screen.

Ndecsteps      = 200;
Nroamingsteps  = Ndecsteps * 10;
Nroamingtrials = 50;
maxdisp        = round(sliderProperties.endstopdistance/5);

sliderProperties.UncertaintySD = S.GUI.UncertaintySD;
maxspeed                       = max(S.GUI.MaxSpeed, 0);
maxspeed                       = min(maxspeed, 100);
sliderProperties.maxspeed      = maxspeed;
%-----------------------------------------------------------------------------------------------------------------
% performance always between 0 and 1
perfcurr      = min(S.GUI.Performance, 1);
perfcurr      = max(perfcurr, 0);
slideroutcome = rand(1) < perfcurr;
sliderProperties.outcome = slideroutcome;
%-----------------------------------------------------------------------------------------------------------------
% decision-time related
maxdt                     = min(S.GUI.DecisionTime/2, 3); % maximum is 3 s or half of DT
dtcurr                    = exprnd(S.GUI.DTimeAvg/log(2)); % transform from median to mean
dtcurr                    = max(dtcurr, 0.02);  % minimum is 20 ms
dtcurr                    = min(dtcurr, maxdt); 
sliderProperties.dectime  = dtcurr;
%-----------------------------------------------------------------------------------------------------------------
% steps for trajectory
decsteps                  = round(randn([Ndecsteps, 1])*sliderProperties.UncertaintySD);
itruncate                 = abs(decsteps) > maxdisp;
decsteps(itruncate)       = sign(decsteps(itruncate)) * maxdisp;
sliderProperties.decsteps = decsteps;
%-----------------------------------------------------------------------------------------------------------------
% reward and return related
rewlicktime                    = max(S.GUI.RewardStayTime, 1e-3);
if sliderProperties.outcome > 0
	sliderProperties.spouttime = rewlicktime; % drink
else
	sliderProperties.spouttime = 0.3; % leave
end
speedreturn                  =  (1 + rand(1))* sliderProperties.maxspeed/2;
sliderProperties.speedreturn = speedreturn;
%-----------------------------------------------------------------------------------------------------------------
sliderchoice = currreward(sliderside);
if sliderside == 2
    sliderchoice = -currreward;
end
if slideroutcome == 0
    sliderchoice = -sliderchoice;
end
sliderProperties.sliderchoice = sliderchoice;
if sliderProperties.sliderchoice>0
    sliderProperties.sidemove   = 'r';
    sliderProperties.endval     = sliderProperties.endstopdistance;
else
    sliderProperties.sidemove   = 'l';
    sliderProperties.endval     = 0;
end
%-----------------------------------------------------------------------------------------------------------------
% ROAMING MODE
% Here we create a trajectory that will be initiated by the state machine
% the trajectory will wait till the robo is available and then start
% roaming
sliderProperties.iroam        = 1;
sliderProperties.iroamtrial   = 1;
sliderProperties.RoamingType  = S.GUI.RoamingType;
sliderProperties.RoamingSD    = sliderProperties.UncertaintySD/3;

roamdecsteps                  = round(randn([Nroamingsteps, 1])*sliderProperties.RoamingSD);
itruncate                     = abs(roamdecsteps) > maxdisp;
roamdecsteps(itruncate)       = maxdisp;
altvec                        = ones(Nroamingsteps, 1);
altvec(2:2:end)               = -altvec(2:2:end);
roamdecsteps                  = abs(roamdecsteps).*altvec;

roamchoices                   = 2 * (rand(Nroamingtrials, 1) > 0.5) - 1;
roamspeedreturn               = (1 + rand(Nroamingtrials, 1))* sliderProperties.maxspeed/2;

sliderProperties.roamdecsteps    = roamdecsteps;
sliderProperties.roamchoices     = roamchoices;
sliderProperties.roamspeedreturn = roamspeedreturn;
sliderProperties.roamingdectimes = exprnd(2 * S.GUI.DTimeAvg/log(2), [Nroamingtrials 1]);
sliderProperties.x               = 0;
%-----------------------------------------------------------------------------------------------------------------
sliderProperties.timeonplat = 0;
if sliderProperties.RoamingType  < 3
    sliderProperties.roamingdectimes = Inf * sliderProperties.roamingdectimes;
end
%-----------------------------------------------------------------------------------------------------------------
end
