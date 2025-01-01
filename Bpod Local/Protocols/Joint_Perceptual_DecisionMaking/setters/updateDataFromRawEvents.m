function BpodSystem = updateDataFromRawEvents(BpodSystem,...
                                              S,RawEvents,...
                                              currentTrial,...
                                              currStim,...
                                              currReward,...
                                              currRewardAmount,...
                                              mousesetting)
    % handle general saving
    
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    BpodSystem.Data.TrialNumber(currentTrial)   = currentTrial;
    BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.Box(currentTrial)           = getBoxFromComputerName();
    
     
    thisTrialRawEventStates = BpodSystem.Data.RawEvents.Trial{currentTrial}.States;
    %% Data extracted from raw events (Dependent on the state machine running (mousesetting))
    if numel(mousesetting) == 1
        initiationTimeToSave = [nan nan];
        outcomeToSave        = [nan nan];
        reactionTimeToSave   = [nan nan];
        decisionTimeToSave   = [nan nan];
        trialTypesToSave     = [nan nan];
        contrastToSave       = [nan nan];
        choiceToSave         = [nan nan];
        
        trialTypesToSave(mousesetting) = currReward;
        contrastToSave(mousesetting)= currStim;
        
        % 1. Initiation time
        if all(isnan(thisTrialRawEventStates.SpontaneousStimulus))
            timeinit = thisTrialRawEventStates.MouseInZone(1);
            isSpontaneous = false;
        else
            timeinit = thisTrialRawEventStates.SpontaneousStimulus(1);
            isSpontaneous = true;
        end

        initiationTimeToSave(mousesetting) = timeinit;
        
        % 2. Trial Outcome
        if ~isnan(thisTrialRawEventStates.Reward(1))
            outcomeToSave(mousesetting) = 1;
        elseif ~isnan(thisTrialRawEventStates.Punish(1))
            outcomeToSave(mousesetting) = 0;
        elseif isnan(thisTrialRawEventStates.MouseInZone(1))%No Start
            outcomeToSave(mousesetting) = -11;
        else %No Choice
            outcomeToSave(mousesetting) = -10;
        end
        
        % 3. Reaction Times
        reactionTimeToSave(mousesetting) = thisTrialRawEventStates.MouseMakingDecision(2)-timeinit;
        
        % 4. Mouse Choice (Redundant but nice to have).
        if outcomeToSave(mousesetting)>=0
            choiceToSave(mousesetting) = (2*outcomeToSave(mousesetting)-1)*currReward;
        end
        % 5. Decision Times
        pin = BpodSystem.Data.RawEvents.Trial{currentTrial}.Events;
        if isfield(pin, 'GlobalTimer1_Start')
            stimstart = pin.GlobalTimer1_Start;
            currdfield = sprintf('BNC%dLow',mousesetting);
            if isfield(pin, currdfield)
                iuse = find(pin.(currdfield)-stimstart>0,1);
                tout = pin.(currdfield)(iuse);
                if numel(tout)== 1
                    decisionTimeToSave(mousesetting) = tout - stimstart;
                end
            end
        end

        BpodSystem.Data.TrialTypes(currentTrial,:)     = trialTypesToSave; % Adds the trial type of the current trial to data
        BpodSystem.Data.InitiationTime(currentTrial,:) = initiationTimeToSave;
        BpodSystem.Data.TrialOutcome(currentTrial,:)   = outcomeToSave;
        BpodSystem.Data.ReactionTimes(currentTrial,:)  = reactionTimeToSave;
        BpodSystem.Data.DecisionTimes(currentTrial,:)  = decisionTimeToSave;
        BpodSystem.Data.MouseChoice(currentTrial,:)    = choiceToSave;
        BpodSystem.Data.RewardAmount(currentTrial,:)   = currRewardAmount.*(outcomeToSave>=0);
        BpodSystem.Data.Contrast(currentTrial,:)       = contrastToSave;
        BpodSystem.Data.isSpontaneous(currentTrial,:)  = isSpontaneous;
        
    elseif numel(mousesetting)==2
        % 1. Initiation time
        if ~isnan(thisTrialRawEventStates.BothMiceInZone(1))
            initiationTimeToSave = repmat(thisTrialRawEventStates.BothMiceInZone(1),[1 2]);
        else
            initiationTimeToSave = [nan nan];
        end
        
        % 2. Trial Outcome
        if ~isnan(thisTrialRawEventStates.BothPunished(1))
            outcomeToSave = [0 0];
        elseif ~isnan(thisTrialRawEventStates.BothRewarded(1))
            outcomeToSave = [1 1];
        elseif ~isnan(thisTrialRawEventStates.M1RewardedM2Punished(1))
            outcomeToSave = [1 0];
        elseif ~isnan(thisTrialRawEventStates.M2RewardedM1Punished(1))
            outcomeToSave = [0 1];
        elseif ~isnan(thisTrialRawEventStates.BothMiceInZone(1))
             outcomeToSave = [-11 -11];
        else %%Special case of single mouse performing goes here
            outcomeToSave = [-10 -10];
        end
        
        % 3. Reaction Times
        stimTime = thisTrialRawEventStates.BothMiceInZone(1);
        if all(outcomeToSave == [1 1]) %Both Rewarded
            if ~isnan(thisTrialRawEventStates.RewardM1First(1))%%M1 Performed First
                reactionTimeM1 = thisTrialRawEventStates.RewardM1First(1)  - stimTime;
                reactionTimeM2 = thisTrialRawEventStates.RewardM2Second(1) - stimTime;
            else %M2 PerformedFirst
                reactionTimeM1 = thisTrialRawEventStates.RewardM1Second(1) - stimTime;
                reactionTimeM2 = thisTrialRawEventStates.RewardM2First(1)  - stimTime;
            end
        elseif all(outcomeToSave == [0 0]) %Both Punished
            if ~isnan(thisTrialRawEventStates.PunishM1First(1))%%M1 Performed First
                reactionTimeM1 = thisTrialRawEventStates.PunishM1First(1) - stimTime;
                reactionTimeM2 = thisTrialRawEventStates.PunishedM1PunishM2Second(1) - stimTime;
            else %M2 PerformedFirst
                reactionTimeM1 = thisTrialRawEventStates.PunishedM2PunishM1Second(1) - stimTime;
                reactionTimeM2 = thisTrialRawEventStates.PunishM2First(1) - stimTime;
            end
        elseif all(outcomeToSave == [1 0]) %M1 Rewarded M2 Punished
            if ~isnan(thisTrialRawEventStates.RewardM1First(1))%%M1 Performed First
                reactionTimeM1 = thisTrialRawEventStates.RewardM1First(1) - stimTime;
                reactionTimeM2 = thisTrialRawEventStates.PunishM2Second(1) - stimTime;
            else %M2 PerformedFirst
                reactionTimeM1 = thisTrialRawEventStates.PunishedM2RewardM1Second(1) - stimTime;
                reactionTimeM2 = thisTrialRawEventStates.PunishM2First(1) - stimTime;
            end
        elseif all(outcomeToSave == [0 1]) %M2 Rewarded M1 Punished
            if ~isnan(thisTrialRawEventStates.PunishM1First(1))%%M1 Performed First
                reactionTimeM1 = thisTrialRawEventStates.PunishM1First(1)            - stimTime;
                reactionTimeM2 = thisTrialRawEventStates.PunishedM1RewardM2Second(1) - stimTime;
            else %M2 PerformedFirst
                reactionTimeM1 = thisTrialRawEventStates.PunishM1Second(1) - stimTime;
                reactionTimeM2 = thisTrialRawEventStates.RewardM2First(1)  - stimTime;
            end
        else %Special case of single mouse performing (not implemented)
            reactionTimeM1 = nan;
            reactionTimeM2 = nan;
        end
        
        
        % 4. Mouse Choice (Redundant but nice to have).
        if all(outcomeToSave == [1 1]) %Both Rewarded
            choiceToSave = currReward;
        elseif all(outcomeToSave == [0 0]) %Both Punished
            choiceToSave = currReward*-1;
        elseif all(outcomeToSave == [1 0]) %M1 Rewarded M2 Punished
            choiceToSave = currReward.*[1 -1];
        elseif all(outcomeToSave == [0 1]) %M2 Rewarded M1 Punished
            choiceToSave = currReward.*[-1 1];
        else %Special case of single mouse performing (not implemented)
            choiceToSave = [nan nan];
        end
        
        % 5. Decision Times
        pin = BpodSystem.Data.RawEvents.Trial{currentTrial}.Events;
        decisionTimeToSave = [nan nan];
        if isfield(pin, 'GlobalTimer1_Start')
            stimstart = pin.GlobalTimer1_Start;
            for ii = 1:2
                currdfield = sprintf('BNC%dLow', ii);
                if isfield(pin, currdfield)
                    iuse = find(pin.(currdfield)-stimstart>0,1);
                    tout = pin.(currdfield)(iuse);
                    if numel(tout)== 1
                        decisionTimeToSave(ii) = tout - stimstart;
                    end
                end
            end
        end
        
        BpodSystem.Data.TrialTypes(   currentTrial,  :) = currReward;
        BpodSystem.Data.InitiationTime(currentTrial, :) = initiationTimeToSave;
        BpodSystem.Data.TrialOutcome(  currentTrial, :) = outcomeToSave;
        BpodSystem.Data.ReactionTimes( currentTrial, :) = [reactionTimeM1 reactionTimeM2];
        BpodSystem.Data.DecisionTimes( currentTrial, :) = decisionTimeToSave;
        BpodSystem.Data.MouseChoice(   currentTrial, :) = choiceToSave;
        BpodSystem.Data.RewardAmount(  currentTrial, :) = currRewardAmount.*(outcomeToSave>=0);
        BpodSystem.Data.Contrast(      currentTrial, :) = currStim;
    else
        error('Incorrect mouse setting.');
    end
end