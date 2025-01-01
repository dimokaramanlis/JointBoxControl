[screenIds, screenInvGammaTables] = checkMonitorIdentity('C:\BoxSettings', false);


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
    [~, success(ii)] = Screen('LoadNormalizedGammaTable', PTB.windows(ii), screenInvGammaTables(:,:,ii));
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
ii = 2;
res = 3*[323 323];
phase = 0;
sc = 150.0;
freq = .01;
tilt = 50;
contrast = 100.0;
aspectratio = 1.0;
nonsymmetric =0;

tw = res(1);
th = res(2);
% pixels, and a RGB color offset of 0.5 -- a 50% gray.
[gabortex,gaborrect] = CreateProceduralGabor(PTB.windows(ii), tw, th, nonsymmetric, [0.5 0.5 0.5 0.0]);

xc = PTB.windowrects(ii, 3)/2 - tw/2;
yc = PTB.windowrects(ii, 4)/2 - th/2 + 100;

dstRect = OffsetRect(gaborrect, xc, yc);
% Draw the gabor once, just to make sure the gfx-hardware is ready for the
% benchmark run below and doesn't do one time setup work inside the
% benchmark loop: See below for explanation of parameters...
Screen('DrawTexture', PTB.windows(ii), gabortex, [], dstRect, 90+tilt, [], [], [], [], kPsychDontDoRotation, [phase+180, freq, sc, contrast, aspectratio, 0, 0, 0]);

% Perform initial flip to gray background and sync us to the retrace:
vbl = Screen('Flip', PTB.windows(ii));
