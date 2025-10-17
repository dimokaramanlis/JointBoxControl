function BpodSystem = updateDataFromRawEvents(BpodSystem, S,RawEvents, currentTrial, ...
                                              currStim,currReward, currRewardAmount,...
                                              mousesetting)
    portids = [4 1; 3 2];
    %-----------------------------------------------------------
    % handle general saving
    
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    BpodSystem.Data.TrialNumber(currentTrial)   = currentTrial;
    BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.Box(currentTrial)           = getBoxFromComputerName();
    
     
    currTrialStates = BpodSystem.Data.RawEvents.Trial{currentTrial}.States;
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
        RewardOutcome        = [nan nan];
        
        trialTypesToSave(mousesetting) = currReward;
        contrastToSave(mousesetting)= currStim;
        
        % 1. Initiation time
        if all(isnan(currTrialStates.SpontaneousStimulus))
            timeinit = currTrialStates.MouseInZone(1);
            isSpontaneous = false;
        else
            timeinit = currTrialStates.SpontaneousStimulus(1);
            isSpontaneous = true;
        end

        initiationTimeToSave(mousesetting) = timeinit;
        
        % 2. Trial Outcome
        if ~isnan(currTrialStates.Reward(1))
            outcomeToSave(mousesetting) = 1;
            RewardOutcome(mousesetting) = 1;
        elseif ~isnan(currTrialStates.Punish(1))
            outcomeToSave(mousesetting) = 0;
            RewardOutcome(mousesetting) = 0;
        elseif isnan(currTrialStates.MouseInZone(1))%No Start
            outcomeToSave(mousesetting) = -11;
        else %No Choice
            outcomeToSave(mousesetting) = -10;
        end
        
        % 3. Reaction Times
        reactionTimeToSave(mousesetting) = currTrialStates.MouseMakingDecision(2)-timeinit;
        
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
        BpodSystem.Data.RewardOutcome(currentTrial,:)  = RewardOutcome;
        
    elseif numel(mousesetting)==2
        % 1. Initiation time
        if ~isnan(currTrialStates.BothMiceInZone(1))
            initiationTimeToSave = repmat(currTrialStates.BothMiceInZone(1),[1 2]);
        else
            initiationTimeToSave = [nan nan];
        end
        
        % 2. Trial Outcome, Reaction Time and Choice
        outcomeToSave = [nan nan];
        reactToSave   = [nan nan];
        choiceToSave  = [nan nan];
        RewardOutcome = [nan nan];
        
        currfields    = fields(currTrialStates);
        stimTime      = currTrialStates.BothMiceInZone(1);
        for imouse = 1:2
            other_mouse = 3-imouse;
            
            %Get outcome
            
            %rewards that happen within soft delay, if they exist, psecond should be 1!
            CorrChoiceNames = {sprintf('CorrectM%dSoftDelay', imouse),... Coop
                                 sprintf('M%dCorrectWaiting', imouse),... Coop
                                 sprintf('BothFirstRewardM%d', other_mouse),...  Coop
                                 sprintf('RewardM%dSecond', imouse),... Coop but its not getting the real first time!!! Also Comp
                                 sprintf('RewardM%dFirst', imouse),... Comp
                                 sprintf('FullRewardM%d', imouse),... Comp
                                 sprintf('M%dCorrectAfterEnd', imouse),... Coop
                                 sprintf('PunishedM%dRewardM%dSecond', other_mouse, imouse)}; %Comp                             
                             
            WrongChoiceNames = {sprintf('M%dWrongFirstBothPunished', imouse),... Coop
                        sprintf('M%dWrongBothPunished', imouse),... Coop
                        sprintf('M%dWrongSecondBothPunished', imouse),... Coop
                        sprintf('PunishM%dFirst', imouse),... Comp
                        sprintf('PunishM%dSecond', imouse),... Comp
                        sprintf('M%dPunished', imouse),...
                        sprintf('M%dWrongAfterEnd', imouse),... Coop
                        sprintf('PunishedM%dPunishM%dSecond', other_mouse, imouse)}; %Comp
                    
            
            mouseCor = nan;
            validfields = currfields(contains(currfields, CorrChoiceNames));
            for ifield = 1:numel(validfields)
                mouseCor = min(mouseCor, min(currTrialStates.(validfields{ifield})));
            end
            
            mouseWrong = nan;
            validfields = currfields(contains(currfields, WrongChoiceNames));
            for ifield = 1:numel(validfields)
                mouseWrong = min(mouseWrong, min(currTrialStates.(validfields{ifield})));
            end
            
            
            if ~isnan(mouseWrong)
                outcomeToSave(imouse) = 0;
                reactToSave(imouse)   = min(mouseWrong) - stimTime;
                choiceToSave(imouse)  = -currReward(imouse);
                RewardOutcome(imouse) = 0;
            end                 
            
            if ~isnan(mouseCor) %register reward after punishment, to garantee first correct response
                outcomeToSave(imouse) = 1;
                reactToSave(imouse)   = min(mouseCor) - stimTime;
                choiceToSave(imouse)  = currReward(imouse);
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
        
        BpodSystem.Data.TrialTypes(   currentTrial,  :) = currReward;
        BpodSystem.Data.InitiationTime(currentTrial, :) = initiationTimeToSave;
        BpodSystem.Data.TrialOutcome(  currentTrial, :) = outcomeToSave;
        BpodSystem.Data.ReactionTimes( currentTrial, :) = reactToSave;
        BpodSystem.Data.DecisionTimes( currentTrial, :) = decisionTimeToSave;
        BpodSystem.Data.MouseChoice(   currentTrial, :) = choiceToSave;

        %%%%% Get reward         
        %%%%% Start Beatriz Edited
        rewcurr  = [0 0];
        
        for imouse = 1:2
            if isnan(reactToSave(imouse))
                continue
            end
            %iother   = mod(imouse, 2) + 1;
                        
            fullrewardnames = {sprintf('RewardM%dFirst', imouse),... Comp
                               sprintf('FullRewardM%d', imouse),... Comp
                               sprintf('PunishedM%dRewardM%dSecond', other_mouse, imouse),... Comp
                               sprintf('BothFirstRewardM%d', imouse)};
            
            secondrewardnames = {sprintf('RewardM%dSecond', imouse)}; %Comp and Coop
                                 %single mice> 'Reward'
                                 
            mouserew = nan;          
            validfields = currfields(contains(currfields, fullrewardnames));
            for ifield = 1:numel(validfields)
                mouserew = min(mouserew, min(currTrialStates.(validfields{ifield})));
            end
            
            secondmouserew = nan;
            validfields = currfields(contains(currfields, secondrewardnames));
            for ifield = 1:numel(validfields)
                secondmouserew = min(secondmouserew, min(currTrialStates.(validfields{ifield})));
            end
            
            
            if ~isnan(mouserew)
                rewcurr(imouse) = currRewardAmount(imouse);
                RewardOutcome (imouse) = 1;
                
            elseif ~isnan(secondmouserew)
                psecond  = min(S.GUI.RewardPercentageSecond, 1);
                psecond  = max(psecond, 0);
                rewcurr(imouse) = currRewardAmount(imouse) * psecond;
                RewardOutcome (imouse) = 0;
            end


        end
   
        BpodSystem.Data.RewardAmount(  currentTrial, :) = rewcurr;

        BpodSystem.Data.RewardOutcome(  currentTrial, :) = RewardOutcome;
        
        
        BpodSystem.Data.Contrast(      currentTrial, :) = currStim;
    else
        error('Incorrect mouse setting.');
    end
end