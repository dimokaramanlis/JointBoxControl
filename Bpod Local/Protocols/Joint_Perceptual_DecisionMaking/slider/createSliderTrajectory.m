function sliderProperties = createSliderTrajectory(S, sliderProperties, currreward, sliderside)
%CREATEANDDRAWTEXTURES Takes the current trial types and creates the
%appropriate textures on the screen.

returnspeedminper = 0.6;
sliderProperties.UncertaintySD = S.GUI.UncertaintySD;
sliderProperties.UncertaintySD = round(max(sliderProperties.UncertaintySD, 0));
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
mindt                     = sliderProperties.timepredictparams(1);
maxdt                     = min(S.GUI.DecisionTime/2, 3); % maximum is 3 s or half of DT
dtcurr                    = S.GUI.DTimeAvg; % transform from median to mean
dtcurr                    = min(dtcurr, maxdt); 
dt                  = generateDecisionTimeFromOutcome(slideroutcome, dtcurr*1e3, maxdt);
sliderProperties.dectime  = dt*1e-3;
%-----------------------------------------------------------------------------------------------------------------
% steps for trajectory
if dtcurr < mindt*0.9
    decsteps = [];
else
    stepduration              = glmval(sliderProperties.timepredictparams, ...
        sliderProperties.UncertaintySD/100, 'identity');
    Ntotal        = floor(sliderProperties.UncertaintySD * dtcurr/stepduration);
    Nstepstake    = ceil(dtcurr/stepduration);
    decsteps      = sliderProperties.UncertaintySD * ones(Nstepstake, 1);
    if sum(decsteps) > Ntotal
        decsteps(end) = Ntotal - sliderProperties.UncertaintySD *(Nstepstake-1);
    end
    decsigns = 2 * (rand(Nstepstake, 1)> 0.5) - 1;
    decsteps = decsteps .* decsigns;
end
sliderProperties.decsteps = decsteps;
%-----------------------------------------------------------------------------------------------------------------
% reward and return related
rewlicktime                    = max(S.GUI.RewardStayTime, 1e-3);
if sliderProperties.outcome > 0
	sliderProperties.spouttime = rewlicktime; % drink
else
	sliderProperties.spouttime = 0.3; % leave
end
speedreturn                  =  (returnspeedminper + rand(1)*(1 - returnspeedminper))* maxspeed;
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
roamingtype                   = S.GUI.RoamingType;
if roamingtype == 3
    roamingtype = 2;
end
sliderProperties.roamtype     = roamingtype;
sliderProperties.iroamtrial   = 1;
sliderProperties.iroamstep    = 1;
sliderProperties.RoamingSD    = round(max(sliderProperties.UncertaintySD, 0));
roamstepduration              = glmval(sliderProperties.timepredictparams, ...
    sliderProperties.RoamingSD/100, 'identity');
sliderProperties.perioduse    = roamstepduration;

if roamingtype == 1
    Nroamingtrials = 1;
else
    Nroamingtrials = 15;
end

roamdectimes = exprnd(3 * S.GUI.DTimeAvg/log(2), [Nroamingtrials 1]); % transform from median to mean
roamdectimes = min(roamdectimes, maxdt); 

roamdecsteps  = cell(Nroamingtrials, 1);
roamspeeds    = cell(Nroamingtrials, 1);
roamnplatform = nan(Nroamingtrials, 1);

for itrial = 1:Nroamingtrials
    %----------------------------------------------------------------------
    % decision steps
    if roamingtype == 1
        dtroam        = 10 * roamstepduration;
    else
        dtroam        = roamdectimes(itrial);
    end
    Ntotal        = floor(sliderProperties.RoamingSD * dtroam/roamstepduration);
    Nstepstake    = ceil(dtroam/roamstepduration);
    decsteps      = sliderProperties.RoamingSD * ones(Nstepstake, 1);
    if sum(decsteps) > Ntotal
        decsteps(end) = Ntotal - sliderProperties.RoamingSD *(Nstepstake-1);
    end

    altvec            = ones(Nstepstake, 1);
    altvec(2:2:end)   = -altvec(2:2:end);
    decsteps          = decsteps .* altvec;
    if roamingtype == 1
        roamnplatform(itrial) = Inf;
    else
        roamnplatform(itrial) = numel(decsteps);
    end
    %----------------------------------------------------------------------
    % spout steps
    if roamingtype == 1
        stepsspout = [];
    else
        currchoice  = 2 * (rand(1)> 0.5) - 1;
        currdist    =  rand(1);
        if currdist> 0.3
            goshort   = false;
            stepstake = floor(sliderProperties.endstopdistance/2);
        else
            goshort   = true;
            stepstake = floor(sliderProperties.endstopdistance/3);
        end
        stepsspout = round(currchoice * stepstake - sum(decsteps));


%         Ntospout    = ceil(sliderProperties.endstopdistance/sliderProperties.RoamingSD/2);
%         stepsspout  = currchoice * sliderProperties.RoamingSD * ones(Ntospout, 1);

%     if sum(stepsspout) > Ntotal
%         decsteps(end) = Ntotal - sliderProperties.RoamingSD *(Nstepstake-1);
%     end
    end
    %----------------------------------------------------------------------
    % wait steps
    if roamingtype == 1
        waitsteps = [];
    else
        Nwaitsteps  = ceil(0.3/roamstepduration);
        waitsteps   = zeros(Nwaitsteps, 1);
    end
    %----------------------------------------------------------------------
    % return steps
    if roamingtype == 1
        returnsteps = [];
    else
        if goshort
            returnsteps = -currchoice * ceil(sliderProperties.endstopdistance/3);
        else
            returnsteps = -currchoice * ceil(sliderProperties.endstopdistance/2);
        end
    end
    %----------------------------------------------------------------------
    allsteps             = cat(1, decsteps, stepsspout, waitsteps, returnsteps);
    roamdecsteps{itrial} = allsteps;

    speedreturn          = (returnspeedminper + rand(1)*(1 - returnspeedminper))* maxspeed;
    speedsteps           = sliderProperties.maxspeed*ones(size(allsteps));
    speedsteps(1:numel(decsteps)) = round(sliderProperties.maxspeed * 0.8);
    speedsteps(end-numel(returnsteps)+1:end)  = speedreturn;
    roamspeeds{itrial}   = speedsteps;
    %----------------------------------------------------------------------
end
sliderProperties.roamdecsteps  = roamdecsteps;
sliderProperties.roamnplatform = roamnplatform;
sliderProperties.roamspeeds    = roamspeeds;
%-----------------------------------------------------------------------------------------------------------------
end
