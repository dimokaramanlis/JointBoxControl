function [PTB,S,BpodSystem,graphics,myPlots] = initOrientationProtocol(BpodSystem, screenIds, invgamma, ops)

%% Load previous parameters (if exist)
[sessionDir,~,~] = fileparts(BpodSystem.Path.CurrentDataFile);
loadanswers = {'Load last setting','Load from session'};
answer = questdlg('How would you like to load the settings?', ...
                  'Settings selection', loadanswers{:},'Load last setting');
Snew = [];
switch answer
    case loadanswers{1}
        % fix the issue
        lastFileName = getlatestfile(sessionDir);
        if ~isempty(lastFileName)
            lastSession = load([sessionDir,filesep,lastFileName]); %Load last most settings saved.
            Snew = lastSession.SessionData.TrialSettings(end); %Last Settings
        else
            Snew = [];
        end
    case loadanswers{2}
        [filepath, selpath] = uigetfile('C:\Data','Select session with old settings');
        lastSession = load(fullfile(selpath, filepath));
        Snew = lastSession.SessionData.TrialSettings(end); %Last Settings
end
S = getDefaultStruct(ops);
if ~isempty(Snew)
    S = updateDefaultStruct(S, Snew);
end

%load updated contrasts
S.GUIMeta.ContrastSet.String = ops.stimsetnames;
BpodParameterGUI('init', S); % Initialize parameter GUI plugin
% ==========================================================================
% Init Psych Screen
PsychDefaultSetup(2);
Screen('Preference', 'Verbosity', 1);
Screen('Preference', 'SkipSyncTests', 2);
% Define black, white and grey
PTB.white = [1,1,1];
PTB.grey =  [0.5,0.5,0.5]; 
PTB.black = [0,0,0];
% Open the screens and apply gamma correction
PTB.windows     = zeros(numel(screenIds), 1);
PTB.windowrects = zeros(numel(screenIds), 4);
PTB.ifis        = zeros(numel(screenIds), 1);
success         = zeros(numel(screenIds), 1);
for ii = 1:numel(screenIds)
    [PTB.windows(ii), PTB.windowrects(ii, :)] = PsychImaging('OpenWindow', screenIds(ii), PTB.grey, [], 32, 2,...
                                     [], [],  kPsychNeed32BPCFloat);
    [~, success(ii)] = Screen('LoadNormalizedGammaTable', PTB.windows(ii), invgamma(:,:,ii));
    PTB.ifis(ii)     = Screen('GetFlipInterval', PTB.windows(ii)); 
end

if any(success==0)
    warning('Gamma tables not loaded properly! Expect screen nonlinearity!' )
end
%==========================================================================
%Flip into grey screen once for startup.
PTB.vbl     = zeros(numel(screenIds), 1);
for ii = 1:numel(screenIds)
    Screen('FillRect', PTB.windows(ii),PTB.grey,[0 0 PTB.windowrects(ii, 3) PTB.windowrects(ii, 4)]);
    PTB.vbl(ii) = Screen('Flip', PTB.windows(ii));
end
%==========================================================================
% Set soft code handler to trigger stimuli
BpodSystem.SoftCodeHandlerFunction = 'StimulusFunctionOrientation';
%==========================================================================
% Setup figure
[myPlots, graphics] = initializePlots(BpodSystem.Status.CurrentSubjectName);
%==========================================================================
end