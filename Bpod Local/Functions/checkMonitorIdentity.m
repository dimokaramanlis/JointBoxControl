function [screenIds, screenInvGammaTables] = checkMonitorIdentity(settings_path, varargin)
%CHECKMONITORIDENTITY Summary of this function goes here
%   Detailed explanation goes here

if nargin >1
    askforconfimation = varargin{1};
else
    askforconfimation = true;
end

PsychDefaultSetup(2);
Screen('Preference', 'Verbosity', 2);
Screen('Preference', 'SkipSyncTests', 2);

% get screen numbers
allScreenIds = Screen('Screens');
xysize   = zeros(numel(allScreenIds), 2);
dispsize = zeros(numel(allScreenIds), 1);
for iscreen = 1:numel(allScreenIds)
    rect = Screen('Rect', allScreenIds(iscreen));
    xysize(iscreen, :) = rect(3:4);
    dispsize(iscreen) = Screen('DisplaySize', allScreenIds(iscreen));
end
% candidate screens
candscreens = all(xysize == [1280, 1024],2) & dispsize == 375;
screenIds = allScreenIds(candscreens); %find(xsize < 1300);
assert(numel(screenIds) == 2, 'Check your monitor settings! There should be two screens with 1280 px width')
% load gamma tables
f1   = dir(fullfile(settings_path, '*mouse2_side1.mat'));
gtb1 = load(fullfile(settings_path,f1.name));
f2   = dir(fullfile(settings_path, '*mouse1_side2.mat'));
gtb2 = load(fullfile(settings_path, f2.name));
screenInvGammaTables = cat(3, gtb1.tabletest, gtb2.tabletest);

% assign ids and tables based on past decision
prevdecision = load(fullfile(settings_path, 'flip_decision.mat'));
if prevdecision.toflip
    screenIds = screenIds([2 1]);
    screenInvGammaTables = screenInvGammaTables(:, :, [2 1]);
end

if askforconfimation
    
    answer = questdlg('Check box screens and press any key after you see both shapes', ...
    'Start dialog', ...
    'OK','OK');

    % draw in both screens
    shapecols    = [1 0 0; 0 0 1];
    for iscreen = 1:2
        [window, windowRect] = PsychImaging('OpenWindow', screenIds(iscreen), [0 0 0]);
        [screenXpixels, screenYpixels] = Screen('WindowSize', window);
        [xCenter, yCenter] = RectCenter(windowRect);
        dotSizePix = min(screenXpixels, screenYpixels)/2;
        baseRect = [0 0 dotSizePix dotSizePix];
        centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
        if iscreen == 1
            Screen('FillOval', window, shapecols(iscreen, :), centeredRect, dotSizePix);
        else
            Screen('FillRect', window, shapecols(iscreen, :), centeredRect);
        end
    
        Screen('Flip', window);
    end
    
    KbStrokeWait;
    sca;
    
    answer = questdlg({'What you should have seen:',...
        '- Screen 2 for Mouse 1: a red circle',...
        '- Screen 1 for Mouse 2: a blue square', ' ',...
        'Would you like to flip the screens?'}, ...
	    'Check screen identity', ...
	    'Screens are OK','Flip Screens','Screens are OK');
    
    % Handle response
    switch answer
        case 'Screens are OK'
            fprintf('Keeping screens as is...\n')
        case 'Flip Screens'
            fprintf('Flipping screens and updating settings...\n')
    
            screenIds            = screenIds([2 1]);
            screenInvGammaTables = screenInvGammaTables(:, :, [2 1]);
    
            toflip               = ~prevdecision.toflip;
            save(fullfile(settings_path, 'flip_decision.mat'), 'toflip');
    end
end

sca;


end

