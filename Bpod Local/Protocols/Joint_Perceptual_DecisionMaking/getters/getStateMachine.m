function [sma,currRewardAmount]= getStateMachine(S,currreward,mousesetting,ops)
%% Trial specific timing values
LEDIntensity = S.GUI.LEDIntensity;

valvetimes         = NaN(4, 1);
valverewards       = NaN(4, 1);
valvetimesSecond   = NaN(4, 1);
% valverewardsSecond = NaN(4, 1);
psecond            = min(S.GUI.RewardPercentageSecond, 1);
psecond            = max(psecond, 0);
for ii = 1:4

    rewvalve           = S.GUI.RewardAmount * getfield(S.GUI,sprintf('RewardMultiplier%d', ii));
    rewvalveSecond     = psecond * rewvalve;
    if rewvalve > 80
        valvetimes(ii) = 1;
    else
        valvetimes(ii) = GetValveTimes(rewvalve, ii);
    end
    %%%%%%%%%%% Start Beatriz Added

    if rewvalveSecond > 80
        valvetimesSecond(ii) = 1;
    else
        valvetimesSecond(ii) = GetValveTimes(rewvalveSecond, ii);
    end
    %%%%%%%%%%% End Beatriz Added

    valverewards(ii) = rewvalve;
%     valverewardsSecond(ii) = rewvalveSecond;
end
reshrew       = valverewards([4, 1; 3, 2]);
% reshrewSecond = valverewardsSecond([4, 1; 3, 2]);
%--------------------------------------------------------------------------
% bug fix for spontaneous trials
if numel(mousesetting)==2
    inittimeout = S.GUI.InitiationTimeout;
else
    inittimeout = S.GUI.InitiationTimeout + randn(1,1) * (S.GUI.InitiationTimeout/5);
    inittimeout = inittimeout * (inittimeout > 0);
end
%--------------------------------------------------------------------------
times.StimulusDuration      = S.GUI.StimulusDuration;
times.PunishmentTimeout     = S.GUI.PunishTimeoutDuration;
times.InitiationTimeout     = inittimeout;
times.ITI                   = (S.GUI.ITIMax-S.GUI.ITIMin).*rand + S.GUI.ITIMin;
times.DecisionTimeout       = S.GUI.DecisionTime;
times.RewardStimulusTimeout = S.GUI.RewardStimulusTimeout;
%--------------------------------------------------------------------------
%% Trial Specific ports, reward actions, punish actions, and stimulus settings
AllLightsOnAction  = {'PWM1', LEDIntensity,'PWM2', LEDIntensity,'PWM3', LEDIntensity,'PWM4', LEDIntensity};
AllLightsOffAction = {'PWM1', 0,'PWM2', 0,'PWM3', 0,'PWM4', 0};
StimulusPresentationAction = {'SoftCode',10, 'GlobalTimerTrig', 1};
if ops.useAIM
    StimulusPresentationAction = [StimulusPresentationAction {'AnalogIn1', ['#' 0]}];
end
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

actions.StartAction                = StartAction;
actions.PunishOutputAction         = PunishOutputAction;
actions.ITIAction                  = ITIAction;
actions.WaitingAction              = WaitingAction;
actions.StimulusPresentationAction = StimulusPresentationActionToUse;
actions.AllLightsOnAction          = AllLightsOnAction;
actions.AllLightsOffAction         = AllLightsOffAction;
%% Set up of a global valves and nosepokes map
%Blue is 1, %Red is -1;
%[m1Red m1Blue; m2Red m2Blue]
valves           = ops.valves;
nosepokes        = ops.nosepokes;
times.m1Red      = valvetimes(1);
times.m1Blue     = valvetimes(4);
times.m2Red      = valvetimes(2);
times.m2Blue     = valvetimes(3);

%%%%%%%%%%% Start Beatriz Added
times.m1RedSecond      = valvetimesSecond(1);
times.m1BlueSecond     = valvetimesSecond(4);
times.m2RedSecond      = valvetimesSecond(2);
times.m2BlueSecond     = valvetimesSecond(3);
%%%%%%%%%%% End Beatriz Added
%% Now checking conditions and getting the correct State Machine
if numel(mousesetting)==2  
    currTrialTypeM1 = currreward(1);
    currTrialTypeM2 = currreward(2);

%%%%%%%%%%% Start Beatriz Added *marked with BA  
    if currTrialTypeM1 == 1 %% Blue
        choices.m1CorrectChoice   = nosepokes.m1Blue;
        choices.m1CorrectValve    = valves.m1Blue;        
        choices.m1ValveTime       = times.m1Blue;
        choices.m1ValveTimeSecond = times.m1BlueSecond; %BA
        choices.m1IncorrectChoice = nosepokes.m1Red;
    elseif currTrialTypeM1 == -1 %% Red
        choices.m1CorrectChoice   = nosepokes.m1Red;
        choices.m1CorrectValve    = valves.m1Red;
        choices.m1ValveTime       = times.m1Red;
        choices.m1ValveTimeSecond = times.m1RedSecond; %BA
        choices.m1IncorrectChoice = nosepokes.m1Blue;
    else
        error('Incorrect trial type for M1. Please check currReward variable');
    end

    if currTrialTypeM2 == 1 %% Blue
        choices.m2CorrectChoice   = nosepokes.m2Blue;
        choices.m2CorrectValve    = valves.m2Blue;
        choices.m2ValveTime       = times.m2Blue;
        choices.m2ValveTimeSecond = times.m2BlueSecond; %BA
        choices.m2InCorrectChoice = nosepokes.m2Red;
    elseif currTrialTypeM2 == -1  %% Red
        choices.m2CorrectChoice   = nosepokes.m2Red;
        choices.m2CorrectValve    = valves.m2Red;
        choices.m2ValveTime       = times.m2Red;
        choices.m2ValveTimeSecond = times.m2RedSecond;  %BA
        choices.m2InCorrectChoice = nosepokes.m2Blue;
    else
        error('Incorrect trial type for M2. Please check currReward variable');
    end

%%%%%%%%%%% End Beatriz Added
    %----------------------------------------------------------------------
    % here we change the conditions for initiation
    conditions.ZoneChangeCondition = {'BNC1High', 'WaitingforMouse2',...
        'BNC2High', 'WaitingforMouse1','Tup', 'customExit'};
    conditions.WaitingForMouse2 = {'BNC2High', 'BothMiceInZone',...
        'BNC1Low', 'WaitingforBothMiceStart','Tup','customExit'};
    conditions.WaitingForMouse1 = {'BNC1High', 'BothMiceInZone',...
        'BNC2Low', 'WaitingforBothMiceStart','Tup','customExit'};
    conditions.CheckZoneOut = {'BNC1Low','BothMiceMakingDecision',...
        'BNC2Low','BothMiceMakingDecision','Tup','customExit'};
    %----------------------------------------------------------------------
    conditions.RewardSecondM1={choices.m1CorrectValve,1};
    conditions.RewardSecondM2={choices.m2CorrectValve,1};
    if S.GUI.RewardPercentageSecond == 0
        conditions.RewardSecondM1={choices.m1CorrectValve,0};
        conditions.RewardSecondM2={choices.m2CorrectValve,0};
    end
    
    if ops.useSlider > 0
        % here we assign slider actions
        switch ops.useSlider
            case 1
                choices.m1CorrectChoice   = 'SoftCode1';
                choices.m1IncorrectChoice = 'SoftCode2';
            case 2
                choices.m2CorrectChoice   = 'SoftCode1';
                choices.m2InCorrectChoice = 'SoftCode2';
        end
    end
    %----------------------------------------------------------------------
%%%%%%%%%%% Start Beatriz Edited
        
    sma = getTwoMiceStateMachine(choices,actions,times,conditions);

    currRewardAmount = NaN(1, 2);
    for ii = 1:2
        currRewardAmount(ii) = reshrew(ii, 1+(1-currreward(ii))/2);
    end

%     currRewardAmountSecond = NaN(1, 2);
%     for ii = 1:2
%         currRewardAmountSecond(ii) = reshrewSecond(ii, 1 + (1 - currreward(ii)) / 2);
%     end

%%%%%%%%%%% End Beatriz Edited

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
    conditions.ZoneChangeCondition      = {choices.MouseInZone, 'InZoneTimer','Tup', 'SpontaneousStimulus'};
    conditions.ZoneTimerChangeCondition = {choices.MouseOutOfZone,'WaitforMouseToInitiate','Tup','MouseInZone'};
    MouseMakingDecisionChangeCondition  = {choices.CorrectChoice, 'Reward','Tup', 'customExit'}; %Port 4 Punish
    if S.GUI.Terminate
        MouseMakingDecisionChangeCondition = [MouseMakingDecisionChangeCondition {choices.IncorrectChoice,'Punish'}];
    end
    conditions.MouseMakingDecisionChangeCondition = MouseMakingDecisionChangeCondition;
    RewardAction = {choices.CorrectValve,'1'};
    if S.GUI.RewardStimulusTimeout > 0
        conditions.RewardChangeCondition = {'Tup','RewardDisplayStimulus'};
        newITI = times.ITI-times.RewardStimulusTimeout;
        if newITI<0
            times.ITI =0;
        else
            times.ITI = newITI;
        end
    else
        RewardAction = [RewardAction {'SoftCode',greyScreenSoftCode}];
        conditions.RewardChangeCondition = {'Tup','customExit'};
    end
    
    if ops.useAIM
        RewardAction = [RewardAction {'AnalogIn1', ['#' mousesetting]}];
        actions.PunishOutputAction = [actions.PunishOutputAction {'AnalogIn1', ['#' mousesetting]}];
    end
    actions.RewardAction  = RewardAction;

    sma = getSingleMiceStateMachine(choices,actions,times,conditions);
    currRewardAmount = [nan nan];
%     currRewardAmountSecond = [nan nan];
    currRewardAmount(mousesetting) = reshrew(mousesetting, 1+(1-currreward)/2);
    %currRewardAmount(mousesetting) = choices.ValveTime;
end
end