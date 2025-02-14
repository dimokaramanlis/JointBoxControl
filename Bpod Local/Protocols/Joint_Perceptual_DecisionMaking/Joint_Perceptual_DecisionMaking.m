function Joint_Perceptual_DecisionMaking
%--------------------------------------------------------------------------
% Written and designed by Anas Masood and Dimokratis Karamanlis
% 202502: Major slider support
% -------------------------------------------------------------------------
global BpodSystem PTB S displayTimer GratingProperties ops...
    myStepperBoard sliderProperties
%----------------------------------------------------------------------------
protocolpath = which('Joint_Perceptual_DecisionMaking');
addpath(addpath(genpath(fileparts(protocolpath))));

% local settings for each box
localsettings = loadLocalSettings();
localsettings.useMouseSlider = false;
% localsettings.useAIM = true;
%----------------------------------------------------------------------------
% set bpod console position in a comfortable place
BpodSystem.GUIHandles.MainFig.Position(1:2) = [10 40];
%----------------------------------------------------------------------------
% define contrast sets
confull      = 1;
contrain     = [0.5, 1];
coneasy      = [0.12, 0.24, 0.50, 1];
conhard      = [0.06, 0.12, 0.24, 0.50, 1];
conhard0     = [0, 0.06, 0.12, 0.24, 0.50, 1]; 
conhard0w50  = [0, 0.06, 0.12, 0.24, 1]; 
stimsets     = {confull, contrain, coneasy, conhard, conhard0, conhard0w50};
stimsetnames = {'Con100', 'Con100_50', 'Con100_to_12', ...
    'Con100_to_6', 'Con100_to_0', 'Con100_to_0_wo50'};
%----------------------------------------------------------------------------
% set global options
ops.degPositive  = 45;
ops.degNegative  = -45;
ops.sliderCOM    = "COM9";
% ops.degPositive  = 45;
% ops.degNegative  = 135;
ops.pulseWinWidth = localsettings.pulseWinWidth;
ops.useAIM        = localsettings.useAIM;
ops.useSlider    = localsettings.useMouseSlider;
ops.degPerPixel  = 92/1280;
ops.screenFs     = 60; % make sure this matches your screen refresh rates!
ops.stimsets     = stimsets;
ops.stimsetnames = stimsetnames;
ops.probsettings = {'Pseudorandom','Alternate','RepeatTrials'};
% nosepoke map
ops.valves.m1Red     = 'Valve1';
ops.nosepokes.m1Red  = 'Port1In';
ops.valves.m1Blue    = 'Valve4';
ops.nosepokes.m1Blue = 'Port4In';
ops.valves.m2Red     = 'Valve2';
ops.nosepokes.m2Red  = 'Port2In';
ops.valves.m2Blue    = 'Valve3';
ops.nosepokes.m2Blue = 'Port3In';
%---------------------------------------------- ------------------------------
% initialize screens
[screenIds, screenInvGammaTables] = checkMonitorIdentity('C:\BoxSettings', true);
%----------------------------------------------------------------------------
% initialize bpod system
[PTB, S, BpodSystem, graphics, myPlots] = initOrientationProtocol(BpodSystem, screenIds, screenInvGammaTables,ops);
%----------------------------------------------------------------------------
% initialize Analog Input Module
if localsettings.useAIM ~=0
    BpodSystem.assertModule('AnalogIn', 1); % The second argument (1) indicates that AnalogIn must be paired with its USB serial port
    A = BpodAnalogIn(BpodSystem.ModuleUSB.AnalogIn1);
    A.SamplingRate = 10000; % Hz
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
if localsettings.useMouseSlider
    sliderinfo = getSliderInfo('C:\BoxSettings', ops.sliderCOM);
    [myStepperBoard, xstart] = initializeSliderPosition(sliderinfo, ops.sliderCOM);
    sliderProperties.xpos    = xstart;
end
%----------------------------------------------------------------------------
answer = questdlg('Start all recordings and video', ...
    'Start dialog', 'OK','OK');
%----------------------------------------------------------------------------
mousesetting = getmousesetting(S.GUI.MouseSetting); % this setting is 1, 2 or [1,2] indicating the sides to be used
setchoose    = stimsets{S.GUI.ContrastSet};
isdependent  = (2 - S.GUI.Dependent);
renewprob    = true;
currreward   = -1; % for debug mode
%===========================================================================

% Main trial loop
for currentTrial = 1:10000
    %----------------------------------------------------------------------------
    S = BpodParameterGUI_improved('sync', S); % Sync parameters with BpodParameterGUI plugin
    ops.degPositive = S.GUI.Angle;
    ops.degNegative = -S.GUI.Angle;
    %----------------------------------------------------------------------------
    % same for mouse setting
    if ~isequal(mousesetting, getmousesetting(S.GUI.MouseSetting))
        mousesetting = getmousesetting(S.GUI.MouseSetting); 
        renewprob = true;
    end

    Nmice = numel(mousesetting);

    % update contrast set if altered
    if ~isequal(setchoose, ops.stimsets{S.GUI.ContrastSet})
        setchoose = ops.stimsets{S.GUI.ContrastSet}; 
        renewprob = true;
    end
 
    % same for dependent/independent
    if ~isequal(isdependent, 2 - S.GUI.Dependent) && Nmice>1
        isdependent = 2 - S.GUI.Dependent; 
        renewprob = true;
    end
    %----------------------------------------------------------------------------

    % get trial set
    trialset    = getTrialSet(setchoose,  Nmice, isdependent);
    if renewprob
        probtrial = ones(size(trialset,1), 1)/size(trialset,1);
        renewprob = false;
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
    % initialize gratings
    [PTB, GratingProperties] = createAndDrawTextures(...
                                             S, PTB, GratingProperties, currstim, mousesetting, ops);
    %----------------------------------------------------------------------------
    % initialize slider
    if localsettings.useMouseSlider
        sliderProperties = createSliderTrajectory(S, sliderProperties, currreward, mousesetting);
    end
    %----------------------------------------------------------------------------
    % prepare and run state machine
    [sma,currRewardAmount] = getStateMachine(S, currreward, mousesetting, ops);
    SendStateMatrix(sma); % Send the state matrix to the Bpod device
    RawEvents = RunStateMatrix; % Run the trial and return events
    %----------------------------------------------------------------------
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned (i.e. if not final trial, interrupted by user)
        BpodSystem = updateDataFromRawEvents(BpodSystem,S,...
                                             RawEvents,currentTrial,...
                                             currstim, currreward,currRewardAmount,...
                                             mousesetting);
        SaveBpodSessionData; % Saves the field to the current data file
        % check if figure is still open
        if ~ishandle(myPlots.PerformanceFigure)
            [myPlots, graphics] = initializePlots(BpodSystem.Status.CurrentSubjectName);
        end
        updatePlots(BpodSystem.Data, BpodSystem.Status.CurrentSubjectName, myPlots, graphics);
    end
    %----------------------------------------------------------------------
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0  % If protocol was stopped, exit the loop
        %----------------------------------------------------------------------
        Screen('CloseAll');
        if exist("displayTimer",'var')
            delete(displayTimer); 
        end
        %----------------------------------------------------------------------
        MouseName = BpodSystem.GUIData.SubjectName;
        ProtocolName =  [S.GUIMeta.ProtocolName.String{S.GUI.ProtocolName}];
        fileName = [datestr(datetime('now'),'yyyymmdd_HHMM_') MouseName];
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
        answer = questdlg('Stop all recordings and video', ...
            'Stop dialog', 'OK','OK');
        %----------------------------------------------------------------------
        if localsettings.useAIM ~=0
            A.scope_StartStop; % Stop Oscope GUI
            A.endAcq; % Close Oscope GUI
            A.stopReportingEvents; % Stop sendi
            copyfile(anlgstremfile, behpath); % copy analog input path
        end
        %----------------------------------------------------------------------
        return
    end
end