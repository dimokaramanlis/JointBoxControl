function Joint_Perceptual_DecisionMaking
%--------------------------------------------------------------------------
% Written and designed by Anas Masood and Dimokratis Karamanlis
% 202502: Major slider support
% -------------------------------------------------------------------------
global BpodSystem PTB S displayTimer GratingProperties ops...
    myStepperBoard sliderProperties sliderTimer;
%----------------------------------------------------------------------------
protocolpath = which('Joint_Perceptual_DecisionMaking');
addpath(addpath(genpath(fileparts(protocolpath))));
%----------------------------------------------------------------------------
% local settings for each box and global options
localsettings = loadLocalSettings();
ops = getGlobalOptions(localsettings);
%----------------------------------------------------------------------------
% set bpod console position in a comfortable place
BpodSystem.GUIHandles.MainFig.Position(1:2) = [10 40];
%---------------------------------------------- ------------------------------
% initialize screens
[screenIds, screenInvGammaTables] = checkMonitorIdentity('C:\BoxSettings', true);
%----------------------------------------------------------------------------
% initialize bpod system
[PTB, S, BpodSystem, myPlots] = initOrientationProtocol(BpodSystem, screenIds, screenInvGammaTables,ops);
%----------------------------------------------------------------------------
% initialize Analog Input Module
if localsettings.useAIM ~=0
    BpodSystem.assertModule('AnalogIn', 1); % The second argument (1) indicates that AnalogIn must be paired with its USB serial port
    A = BpodAnalogIn(BpodSystem.ModuleUSB.AnalogIn1);
    A.SamplingRate    = 10000; % Hz
    A.nActiveChannels = 3; % Record from up to 3 channels
    A.Stream2USB(localsettings.useAIM) = 1; % Configure only channels 1 and 3 for USB streaming
    anlgstremfile = fullfile('D:\ExtraData', sprintf('%s_%s_analog.mat', ...
        datestr(datetime('now'),'yyyymmddHHMM'), BpodSystem.Status.CurrentSubjectName));
    if exist(anlgstremfile,'file')
        delete(anlgstremfile);
    end
    A.USBStreamFile = anlgstremfile; % Set datafile for analog data captured in this session
    A.scope; % Launch Scope GUI
    A.scope_StartStop % Start USB streaming + data logging
end
%----------------------------------------------------------------------------
% initialize Mouse Slider
if localsettings.useMouseSlider > 0
    sliderinfo = getSliderInfo('C:\BoxSettings', ops.sliderCOM);
    [myStepperBoard, xstart] = initializeSliderPosition(sliderinfo, ops.sliderCOM);
	sliderProperties         = sliderinfo;
    sliderProperties.xpos    = xstart;
end
%----------------------------------------------------------------------------
questdlg('Start all recordings and video', 'Start dialog', 'OK','OK');
%----------------------------------------------------------------------------
mousesetting = getmousesetting(S.GUI.MouseSetting); % this setting is 1, 2 or [1,2] indicating the sides to be used
setchoose    = {ops.stimsets{S.GUI.ContrastSet1}, ops.stimsets{S.GUI.ContrastSet2}};
isdependent  = (2 - S.GUI.Dependent);
renewprob    = true;
currreward   = -1; % for debug mode
%===========================================================================

% Main trial loop
for currentTrial = 1:10000
    %----------------------------------------------------------------------------
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    ops.degPositive   = S.GUI.Angle;
    ops.degNegative   = -S.GUI.Angle;
    %----------------------------------------------------------------------------
    sliderstruct        = struct();
    optostruct          = struct(); 
    optostruct.isopto   = false;
    optostruct.optoside = ops.useOpto;
    %----------------------------------------------------------------------------
    % same for mouse setting
    if ~isequal(mousesetting, getmousesetting(S.GUI.MouseSetting))
        mousesetting = getmousesetting(S.GUI.MouseSetting); 
        renewprob = true;
    end

    Nmice = numel(mousesetting);

    % update contrast set if altered
    if ~isequal(setchoose, {ops.stimsets{S.GUI.ContrastSet1}, ops.stimsets{S.GUI.ContrastSet2}})
        setchoose = {ops.stimsets{S.GUI.ContrastSet1}, ops.stimsets{S.GUI.ContrastSet2}}; 
        renewprob = true;
    end
 
    % same for dependent/independent
    if ~isequal(isdependent, 2 - S.GUI.Dependent) && Nmice>1
        isdependent = 2 - S.GUI.Dependent; 
        renewprob = true;
    end
    %----------------------------------------------------------------------------
    % get trial set
    trialset    = getTrialSet(setchoose,  mousesetting, isdependent);
    if renewprob
        probtrial      = ones(size(trialset,1), 1)/size(trialset,1);
        renewprob      = false;
        if ops.useOpto > 0
            opto_accum     = ones(size(trialset,1), 1) * S.GUI.ProbOpto;
        end
    end
    %----------------------------------------------------------------------------
    % debugging options    
    debugmode = (S.GUI.ProbabilityBlue~=0.5 || S.GUI.ProbabilitySetting > 1) & (Nmice==1);        
    %----------------------------------------------------------------------
    if debugmode
        if isfield(BpodSystem.Data, 'Contrast')
            conhistory    = BpodSystem.Data.Contrast(:, mousesetting);
            choicehistory = BpodSystem.Data.MouseChoice(:, mousesetting);
        else
            conhistory    = [];
            choicehistory = [];
        end
        [currstim, currreward] = debugStimReward(S, trialset, currreward, conhistory, choicehistory);
    else
         % draw stimulus
        [newId, probtrial] = sampleAndRemove(probtrial);
        currstim   = trialset(newId, :);
        % set reward side
        currreward = getTrialReward(currstim, isdependent); % find rewarded sides and correct for zero contrast.
    end
    %----------------------------------------------------------------------
    % initialize slider
    if ops.useSlider > 0
        sliderProperties = createSliderTrajectory(S, sliderProperties, currreward,...
            ops.useSlider);
        sliderProperties.side = ops.useSlider;
        if Nmice == 2
            prevstim = currstim(:, ops.useSlider);
            currstim(:, ops.useSlider) = eps * sign(prevstim);
        end
    end
    %----------------------------------------------------------------------------
    if ops.useOpto > 0
        current_prob = max(0, min(1, opto_accum(newId)));
        isOpto       = false;
        
        if rand(1) < current_prob
            isOpto   = true;
        end
        opto_accum(newId) = opto_accum(newId) + S.GUI.ProbOpto - isOpto;
        optostruct.isopto = isOpto;
    end
    %----------------------------------------------------------------------------
    % initialize gratings
    [PTB, GratingProperties] = createAndDrawTextures(...
                                             S, PTB, GratingProperties, currstim, mousesetting, ops);
    %----------------------------------------------------------------------------
    % prepare and run state machine
    [sma,currRewardAmount] = getStateMachine(S, currreward, mousesetting, optostruct.isopto, ops);
    SendStateMatrix(sma); % Send the state matrix to the Bpod device
    RawEvents = RunStateMatrix; % Run the trial and return events
    %----------------------------------------------------------------------
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned (i.e. if not final trial, interrupted by user)
        if ops.useSlider > 0
            sliderstruct = sliderProperties;
        end
        BpodSystem = updateDataFromRawEvents(BpodSystem,S,...
                                             RawEvents,currentTrial,...
                                             currstim, currreward,currRewardAmount,...
                                             mousesetting, optostruct, sliderstruct);
        SaveBpodSessionData; % Saves the field to the current data file
        % check if figure is still open
        if ~ishandle(myPlots.PerformanceFigure)
            myPlots = initializePlots(BpodSystem.Status.CurrentSubjectName);
        end
        updatePlots(BpodSystem.Data, BpodSystem.Status.CurrentSubjectName, myPlots, localsettings.runSimplePlots);
    end
    %----------------------------------------------------------------------
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0  % If protocol was stopped, exit the loop
        %----------------------------------------------------------------------
        % we first stop the slider
        if ops.useSlider > 0 && exist("sliderTimer",'var')
            if any(contains(fieldnames(sliderTimer), 'StopFcn'))
                if ~isempty(sliderTimer.StopFcn)
                    sliderTimer.stop();
                end
            end
            delete(sliderTimer);
        end
        %----------------------------------------------------------------------
        % we then clear the screen
        Screen('CloseAll');
        if exist("displayTimer",'var')
            delete(displayTimer); 
        end
        %----------------------------------------------------------------------
        MouseName    = BpodSystem.GUIData.SubjectName;
        ProtocolName = [S.GUIMeta.ProtocolName.String{S.GUI.ProtocolName}];
        fileName     = [datestr(datetime('now'),'yyyymmdd_HHMM_') MouseName];
        if exist('PerformanceFigure','var')
            %myPlots.panhandle.export();
            print(myPlots.PerformanceFigure,[sessionDir filesep MouseName '_' datestr(datetime('now'),'yyyy.mm.dd.HH.MM') '.jpeg'],'-djpeg','-r600');
        end
        %==================================================================
        % saving is always active
        datetext     = datestr(datetime('now'),'yyyymmdd');
        [behpath, ~] = generateSavePaths(MouseName, ProtocolName, datetext);

        if exist(BpodSystem.Path.CurrentDataFile,'file')==2
            copyfile(BpodSystem.Path.CurrentDataFile, [behpath filesep fileName '.mat']);
            print(myPlots.PerformanceFigure,[behpath filesep fileName '.jpeg'],'-djpeg','-r600');
        else
            warning('No File to Copy! Please check raw data!');
        end
    
        %==================================================================
        if localsettings.useMouseSlider
            myStepperBoard.close();
        end
        %==================================================================
        questdlg('Stop all recordings and video', 'Stop dialog', 'OK','OK');
        %----------------------------------------------------------------------
        if localsettings.useAIM ~=0
            A.scope_StartStop; % Stop Oscope GUI
            A.endAcq; % Close Oscope GUI
            A.stopReportingEvents; % Stop sendi
            copyfile(anlgstremfile, behpath); % copy analog input path
        end
        %----------------------------------------------------------------------
        warning off;
        rmpath(genpath(fileparts(protocolpath))); %remove path from list
        warning on;
        %----------------------------------------------------------------------
        return
    end
end