function [sma,currRewardAmount]= getStateMachine(S,currreward,mousesetting,ops)
%% Trial specific timing values
LEDIntensity = S.GUI.LEDIntensity;

valvetimes   = NaN(4, 1);
valverewards = NaN(4, 1);
for ii = 1:4
    rewvalve = S.GUI.RewardAmount * getfield(S.GUI,sprintf('RewardMultiplier%d', ii));
    if rewvalve > 80
        valvetimes(ii) = 1;
    else
        valvetimes(ii) = GetValveTimes(rewvalve, ii);
    end
    
    valverewards(ii) = rewvalve;
end
reshrew = valverewards([4, 1; 3, 2]);
%--------------------------------------------------------------------------
% bug fix for spontaneous trials
if numel(mousesetting)==2
    inittimeout = S.GUI.InitiationTimeout;
else
    inittimeout = S.GUI.InitiationTimeout + randn(1,1) * (S.GUI.InitiationTimeout/5);
    inittimeout = inittimeout * (inittimeout > 0);
end
%--------------------------------------------------------------------------
times.StimulusDuration  = S.GUI.StimulusDuration;
times.PunishmentTimeout = S.GUI.PunishTimeoutDuration;
times.InitiationTimeout = inittimeout;
times.ITI               = (S.GUI.ITIMax-S.GUI.ITIMin).*rand + S.GUI.ITIMin;
times.DecisionTimeout   = S.GUI.DecisionTime;
times.RewardStimulusTimeout = S.GUI.RewardStimulusTimeout;

%% Trial Specific ports, reward actions, punish actions, and stimulus settings
AllLightsOnAction  = {'PWM1', LEDIntensity,'PWM2', LEDIntensity,'PWM3', LEDIntensity,'PWM4', LEDIntensity};
AllLightsOffAction = {'PWM1', 0,'PWM2', 0,'PWM3', 0,'PWM4', 0};
StimulusPresentationAction = {'SoftCode',10, 'GlobalTimerTrig', 1, 'AnalogIn1', ['#' 0]};
greyScreenSoftCode  = 100;
blackScreenSoftCode = 200;
if S.GUI.BlackScreen
    PunishOutputSoftCode = blackScreenSoftCode;
else
    PunishOutputSoftCode = greyScreenSoftCode;
end
StartAction        = [{'SoftCode',101} AllLightsOnAction];
PunishOutputAction = [{'SoftCode',PunishOutputSoftCode} AllLightsOffAction];
ITIAction          = [{'SoftCode',greyScreenSoftCode} AllLightsOffAction];
WaitingAction      = AllLightsOnAction;
StimulusPresentationActionToUse = [StimulusPresentationAction AllLightsOnAction]; %%Binary string for 


actions.StartAction        = StartAction;
actions.PunishOutputAction = PunishOutputAction;
actions.ITIAction          = ITIAction;
actions.WaitingAction      = WaitingAction;
actions.StimulusPresentationAction = StimulusPresentationActionToUse;
actions.AllLightsOnAction = AllLightsOnAction;
actions.AllLightsOffAction = AllLightsOffAction;
%% Set up of a global valves and nosepokes map
%Blue is 1, %Red is -1;
%[m1Red m1Blue; m2Red m2Blue]
valves = ops.valves;
nosepokes = ops.nosepokes;
times.m1Red      = valvetimes(1);
times.m1Blue     = valvetimes(4);
times.m2Red      = valvetimes(2);
times.m2Blue     = valvetimes(3);
%% Now checking conditions and getting the correct State Machine
    if numel(mousesetting)==2  
        currTrialTypeM1 = currreward(1);
        currTrialTypeM2 = currreward(2);
        if currTrialTypeM1 == 1 %% Blue
            choices.m1CorrectChoice   = nosepokes.m1Blue;
            choices.m1CorrectValve    = valves.m1Blue;
            choices.m1ValveTime       = times.m1Blue;
            choices.m1IncorrectChoice = nosepokes.m1Red;
        elseif currTrialTypeM1 == -1 %% Red
            choices.m1CorrectChoice   = nosepokes.m1Red;
            choices.m1CorrectValve    = valves.m1Red;
            choices.m1ValveTime       = times.m1Red;
            choices.m1IncorrectChoice = nosepokes.m1Blue;
        else
            error('Incorrect trial type for M1. Please check currReward variable');
        end

        if currTrialTypeM2 == 1 %% Blue
            choices.m2CorrectChoice   = nosepokes.m2Blue;
            choices.m2CorrectValve    = valves.m2Blue;
            choices.m2ValveTime       = times.m2Blue;
            choices.m2InCorrectChoice = nosepokes.m2Red;
        elseif currTrialTypeM2 == -1  %% Red
            choices.m2CorrectChoice   = nosepokes.m2Red;
            choices.m2CorrectValve    = valves.m2Red;
            choices.m2ValveTime       = times.m2Red;
            choices.m2InCorrectChoice = nosepokes.m2Blue;
        else
            error('Incorrect trial type for M2. Please check currReward variable');
        end
        sma = getTwoMiceStateMachine(choices,actions,times);
        %currRewardAmount = [choices.m1ValveTime choices.m2ValveTime];
        
        currRewardAmount = NaN(1, 2);
        for ii = 1:2
            currRewardAmount(ii) = reshrew(ii, 1+(1-currreward(ii))/2);
        end
        
    else
        currTrialType = currreward;
        if mousesetting==1
            choices.MouseInZone    = 'BNC1High';
            choices.MouseOutOfZone = 'BNC1Low';
            if currTrialType == 1 % blue side
                choices.CorrectChoice   = nosepokes.m1Blue;
                choices.CorrectValve    = valves.m1Blue;
                choices.ValveTime       = times.m1Blue;
                choices.IncorrectChoice = nosepokes.m1Red;
            elseif currTrialType == -1 % red side
                choices.CorrectChoice   = nosepokes.m1Red;
                choices.CorrectValve    = valves.m1Red;
                choices.ValveTime       = times.m1Red;
                choices.IncorrectChoice = nosepokes.m1Blue;
            end
        elseif mousesetting==2
            choices.MouseInZone    = 'BNC2High';
            choices.MouseOutOfZone = 'BNC2Low';
            if currTrialType == 1 % blue side
                choices.CorrectChoice   = nosepokes.m2Blue;
                choices.CorrectValve    = valves.m2Blue;
                choices.ValveTime       = times.m2Blue;
                choices.IncorrectChoice = nosepokes.m2Red;
            elseif currTrialType == -1 % red side
                choices.CorrectChoice   = nosepokes.m2Red;
                choices.CorrectValve    = valves.m2Red;
                choices.ValveTime       = times.m2Red;
                choices.IncorrectChoice = nosepokes.m2Blue;
            end
        else
            error('Incorrect mouse setting provided. Mouse setting can only be 1,2, or [1,2]');
        end
        %% Left or Right specific settings for state machine
        conditions.ZoneChangeCondition         = {choices.MouseInZone, 'InZoneTimer','Tup', 'SpontaneousStimulus'};
        conditions.ZoneTimerChangeCondition    = {choices.MouseOutOfZone,'WaitforMouseToInitiate','Tup','MouseInZone'};
        MouseMakingDecisionChangeCondition =  {choices.CorrectChoice, 'Reward','Tup', 'customExit'}; %Port 4 Punish
        if S.GUI.Terminate
            MouseMakingDecisionChangeCondition = [MouseMakingDecisionChangeCondition {choices.IncorrectChoice,'Punish'}];
        end
        conditions.MouseMakingDecisionChangeCondition = MouseMakingDecisionChangeCondition;
        RewardAction = {choices.CorrectValve,'1'};
        if S.GUI.RewardStimulusTimeout > 0
            RewardAction = [RewardAction {'AnalogIn1',  ['#' mousesetting]}];
            conditions.RewardChangeCondition = {'Tup','RewardDisplayStimulus'};
            newITI = times.ITI-times.RewardStimulusTimeout;
            if newITI<0
                times.ITI =0;
            else
                times.ITI = newITI;
            end
        else
            RewardAction = [RewardAction {'SoftCode',greyScreenSoftCode, 'AnalogIn1', ['#' mousesetting]}];
            conditions.RewardChangeCondition = {'Tup','customExit'};
        end
        actions.RewardAction        = RewardAction;
        actions.PunishOutputAction = [actions.PunishOutputAction {'AnalogIn1', ['#' mousesetting]}];
        
        sma = getSingleMiceStateMachine(choices,actions,times,conditions);
        currRewardAmount = [nan nan];
        currRewardAmount(mousesetting) = reshrew(mousesetting, 1+(1-currreward)/2);
        %currRewardAmount(mousesetting) = choices.ValveTime;
    end
end