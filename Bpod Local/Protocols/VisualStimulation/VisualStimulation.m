function VisualStimulation
%----------------------------------------------------------------------------
global BpodSystem PTB StimPara
addpath(addpath(genpath('./')));

localsettings = loadLocalSettings();

%----------------------------------------------------------------------------
% make sure screens work
[screenIds, screenInvGammaTables] = checkMonitorIdentity('C:\BoxSettings', false);
[PTB.windows, PTB.windowrects]    = prepareStimulusBackground(screenIds, screenInvGammaTables, 0);

% get ifis
for ii = 1:numel(screenIds)
    PTB.ifis(ii)     = Screen('GetFlipInterval', PTB.windows(ii)); 
end
%----------------------------------------------------------------------------
% decide on what to show by reading text files
degPerPixel = 92/1280;
%----------------------------------------------------------------------------
% start analog input module
if localsettings.useAIM ~=0
    BpodSystem.assertModule('AnalogIn', 1); % The second argument (1) indicates that AnalogIn must be paired with its USB serial port
    A = BpodAnalogIn(BpodSystem.ModuleUSB.AnalogIn1);
    A.SamplingRate = 10000; % Hz
    A.nActiveChannels = 3; % Record from up to 2 channels
    A.Stream2USB(localsettings.useAIM) = 1; % Configure only channels 1 and 3 for USB streaming
    anlgstremfile = fullfile('D:\ExtraData', sprintf('%s_%s_visualstim_analog.mat', ...
        datestr(datetime('now'),'yyyymmdd_HHMM_'), BpodSystem.Status.CurrentSubjectName));
    if exist(anlgstremfile,'file')
        delete(anlgstremfile);
    end
    A.USBStreamFile = anlgstremfile; % Set datafile for analog data captured in this session
    A.scope; % Launch Scope GUI
    A.scope_StartStop % Start USB streaming + data logging
end
%------------------------------------------------------------------------------
answer = questdlg('Check settings and start video', ...
    'Start dialog', 'OK','OK');
% %----------------------------------------------------------------------------
stimulishow       = {'NaturalisticWaves','Chirp'};%{'Chirp', 'NaturalisticWaves'};
handlerfuns       = cellfun(@(x) sprintf('%sStimulusFunction',x),stimulishow, 'un',0);
Nstimuli          = numel(handlerfuns);
betweenstimframes = 60;
% make chirp so that it starts with a white step
wp = 50;
%----------------------------------------------------------------------------
for iscreen = 1:numel(screenIds)
    Screen('FillRect', PTB.windows(iscreen), 0.5, PTB.windowrects(iscreen,:));
     Screen('FillRect', PTB.windows(iscreen), 0, ...
         [PTB.windowrects(iscreen,3:4)-wp PTB.windowrects(iscreen, 3:4)]);
    PTB.vbls(iscreen) = Screen('Flip', PTB.windows(iscreen));
end
%----------------------------------------------------------------------------
% test A.write('#', 1);

allstimpara = cell(Nstimuli, 1);
for istim = 1:Nstimuli
    % change softcodehandler
    BpodSystem.SoftCodeHandlerFunction = handlerfuns{istim};
    [StimPara, PTB] = getStimulusData(stimulishow{istim}, PTB, degPerPixel);
    allstimpara{istim} = StimPara;
    % decide on output actions
    if localsettings.useAIM ~=0
        outacts = {'AnalogIn1', ['#' istim]};
    else
        outacts = {};
    end
    for itrial = 1:StimPara.Nstimtrials
        % run state machine quickly to mark events
        sma = NewStateMachine(); % Initialize new state machine description
        sma = AddState(sma, 'Name', 'customExit', ...
                'Timer', 0, ...
                'StateChangeConditions', {'Tup','exit'},...
                'OutputActions',outacts);
        SendStateMatrix(sma); % Send the state matrix to the Bpod device
        RawEvents = RunStateMatrix; % Run the trial and return events
        eval(handlerfuns{istim});
        HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    end
    % flip screen back to gray
    for iscreen = 1:numel(screenIds)
        Screen('FillRect', PTB.windows(iscreen), 0.5, PTB.windowrects(iscreen,:));
        Screen('FillRect', PTB.windows(iscreen), 0, ...
                    [PTB.windowrects(iscreen,3:4)-wp PTB.windowrects(iscreen, 3:4)]);
        PTB.vbls(iscreen) = Screen('Flip', PTB.windows(iscreen),  PTB.vbls(iscreen) + (betweenstimframes - 0.5) * mean(PTB.ifis));
    end
    
end
%-------------------------------------------------------------------------
answer = questdlg('Stop all recordings and video', ...
            'Stop dialog', 'OK','OK');
%-------------------------------------------------------------------------
if localsettings.useAIM
    A.scope_StartStop; % Stop Oscope GUI
    A.endAcq; % Close Oscope GUI
    A.stopReportingEvents; % Stop sendi
end
sca; % turn off screen
%-------------------------------------------------------------------------
% save data and make folders
MouseName    = BpodSystem.Status.CurrentSubjectName;
ProtocolName = 'VisualStimulation';
datetext    = datestr(datetime('now'),'yyyymmdd');
pathToCopy  = fullfile('C:\Data\', MouseName, 'Behavior', ProtocolName, datetext, 'Session1');
fileName    = sprintf('%s_%s_visstimparams.mat',datestr(datetime('now'),'yyyymmdd_HHMM'),MouseName);

if ~exist(pathToCopy,'dir'), mkdir(pathToCopy); end
if localsettings.useAIM ~=0
    copyfile(anlgstremfile, pathToCopy); % copy analog input path
end
save(fullfile(pathToCopy, fileName), 'allstimpara','-mat')
% if exist(BpodSystem.Path.CurrentDataFile,'file')==2
%     copyfile(BpodSystem.Path.CurrentDataFile,[pathToCopy filesep fileName '.mat']);
%     print(myPlots.PerformanceFigure,[pathToCopy filesep fileName '.jpeg'],'-djpeg','-r600');
% else
%     error('No File to Copy! Please check raw data!');
%     return
% end
% make filming path for the corresponding video
filmingPath = fullfile('C:\Data\', MouseName, 'Filming',  ProtocolName, datetext, 'Session1');
if ~exist(filmingPath,'dir'), mkdir(filmingPath); end
%-------------------------------------------------------------------------
% end protocol
BpodSystem.Status.BeingUsed = 0;
%-------------------------------------------------------------------------
end