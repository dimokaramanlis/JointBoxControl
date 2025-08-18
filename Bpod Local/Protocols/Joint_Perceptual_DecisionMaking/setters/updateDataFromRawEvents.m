function BpodSystem = updateDataFromRawEvents(BpodSystem, S,RawEvents, currentTrial, ...
                                              currStim,currReward, currRewardAmount,...
                                              mousesetting, sliderstruct)
    portids = [4 1; 3 2];
    %-----------------------------------------------------------
    % handle general saving
    
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    BpodSystem.Data.TrialNumber(currentTrial)   = currentTrial;
    BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.Box(currentTrial)           = getBoxFromComputerName();
    
     
    thisTrialRawEventStates = BpodSystem.Data.RawEvents.Trial{currentTrial}.States;
    %-----------------------------------------------------------
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
            stimstart  = pin.GlobalTimer1_Start;
            currdfield = sprintf('BNC%dLow',mousesetting);
            portblue   = sprintf('Port%dIn', portids(mousesetting, 1));
            portred    = sprintf('Port%dIn', portids(mousesetting, 2));
            portevents = [];
            if isfield(pin, portred)
                portevents = [portevents pin.(portred)];
            end
            if isfield(pin, portblue)
                portevents = [portevents pin.(portblue)];
            end
            portevents = sort(portevents, 'ascend');
            idpoke     = find(portevents - stimstart> 0, 1);
            if isfield(pin, currdfield) && ~isempty(idpoke)
                iuse = pin.(currdfield)-stimstart>0;
                tout = pin.(currdfield)(iuse);
                ilast = find(portevents(idpoke) - tout > 0, 1,'last');
                if numel(ilast)== 1
                    decisionTimeToSave(mousesetting) = tout(ilast) - stimstart;
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
        
        % 2. Trial Outcome, Reaction Time and Choice
        outcomeToSave = [nan nan];
        reactToSave   = [nan nan];
        choiceToSave  = [nan nan];
        for imouse = 1:2
            rewardfirst  = sprintf('RewardM%dFirst', imouse);
            rewardsecond = sprintf('RewardM%dSecond', imouse);
            mouserew     = min([thisTrialRawEventStates.(rewardfirst), ...
                thisTrialRawEventStates.(rewardsecond)], [], 'omitnan');
            
            punishfirst  = sprintf('PunishM%dFirst', imouse);
            punishsecond = sprintf('PunishM%dSecond', imouse);
            mousepun    = min([thisTrialRawEventStates.(punishfirst), ...
                thisTrialRawEventStates.(punishsecond)], [], 'omitnan');

            if ~isnan(mouserew)
                outcomeToSave(imouse) = 1;
                reactToSave(imouse)   = mouserew;
                choiceToSave(imouse)  = currReward(imouse);
            end
            if ~isnan(mousepun)
                outcomeToSave(imouse) = 0;
                reactToSave(imouse)   = mousepun;
                choiceToSave(imouse)  = -currReward(imouse);
            end
            
        end
       
        % 5. Decision Times
        pin = BpodSystem.Data.RawEvents.Trial{currentTrial}.Events;
        decisionTimeToSave = [nan nan];
        if isfield(pin, 'GlobalTimer1_Start')
            stimstart = pin.GlobalTimer1_Start;
            for ii = 1:2
                currdfield = sprintf('BNC%dLow', ii);
                portblue   = sprintf('Port%dIn', portids(ii, 1));
                portred    = sprintf('Port%dIn', portids(ii, 2));
                portevents = [];
                if isfield(pin, portred)
                    portevents = [portevents pin.(portred)];
                end
                if isfield(pin, portblue)
                    portevents = [portevents pin.(portblue)];
                end
                portevents = sort(portevents, 'ascend');
                idpoke     = find(portevents - stimstart> 0, 1);
                if isfield(pin, currdfield) && ~isempty(idpoke)
                    iuse = pin.(currdfield)-stimstart>0;
                    tout = pin.(currdfield)(iuse);
                    ilast = find(portevents(idpoke) - tout > 0, 1,'last');
                    if numel(ilast)== 1
                        decisionTimeToSave(ii) = tout(ilast) - stimstart;
                    end
                end
            end
        end

        if isfield(sliderstruct, 'dectime')
            decisionTimeToSave(sliderstruct.side) = sliderstruct.dectime;
            BpodSystem.Data.DecisionSteps(currentTrial, :) = {sliderstruct.decsteps};
        end
        
        BpodSystem.Data.TrialTypes(   currentTrial,  :) = currReward;
        BpodSystem.Data.InitiationTime(currentTrial, :) = initiationTimeToSave;
        BpodSystem.Data.TrialOutcome(  currentTrial, :) = outcomeToSave;
        BpodSystem.Data.ReactionTimes( currentTrial, :) = reactToSave;
        BpodSystem.Data.DecisionTimes( currentTrial, :) = decisionTimeToSave;
        BpodSystem.Data.MouseChoice(   currentTrial, :) = choiceToSave;

        psecond            = min(S.GUI.RewardPercentageSecond, 1);
        psecond            = max(psecond, 0);
        %%%%% Start Beatriz Edited
        rewcurr  = [0 0];
        for imouse = 1:2
            fieldfirst = sprintf('RewardM%dFirst', imouse);
            if ~isnan(thisTrialRawEventStates.(fieldfirst))
                rewcurr(imouse) = currRewardAmount(imouse);
            end
            fieldsecond = sprintf('RewardM%dSecond', imouse);
            if ~isnan(thisTrialRawEventStates.(fieldsecond))
                rewcurr(imouse) = currRewardAmount(imouse) * psecond;
            end
        end
    
        BpodSystem.Data.RewardAmount(  currentTrial, :) = rewcurr;
        
        
%         if all(outcomeToSave == [1 1]) % For both mice rewarded
%             if ~isnan(thisTrialRawEventStates.RewardM1First(1)) % For M1 rewarded first
%                 currRewardAmount(2) = currRewardAmount(2) * psecond;
%             else % For M2 rewarded first
%                 currRewardAmount(1) = currRewardAmount(1) * psecond;
%             end
%         end
%         %%%%% End Beatriz Edited
%         BpodSystem.Data.RewardAmount(  currentTrial, :) = currRewardAmount.*(outcomeToSave>=0);
        BpodSystem.Data.Contrast(      currentTrial, :) = currStim;
    else
        error('Incorrect mouse setting.');
    end
end