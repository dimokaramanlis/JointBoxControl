function [PTB, GratingProperties] = createAndDrawTextures(S, PTB, GratingProperties, currcon, mousesetting, ops)
%CREATEANDDRAWTEXTURES Takes the current trial types and creates the
%appropriate textures on the screen.

%-----------------------------------------------------------------------------------------------------------------
% if there is only one mouse, contrast of other mouse is always zero
conplot   = zeros(1, 2);
orplot    = zeros(1, 2);
orvec     = [ops.degNegative ops.degPositive; ops.degPositive ops.degNegative];
%-----------------------------------------------------------------------------------------------------------------
% special cases
if S.GUI.FlipStimulusOrientation
    orvec = flipud(orvec);
end

if S.GUI.ScreenSetting == 2 %%&& numel(mousesetting)==1
    % flip mouse setting
    mousesetting = 1 + mod(mousesetting,2);
end

% S.GUI.ScreenSetting
if S.GUI.ScreenSetting == 3 && numel(mousesetting)==1
    showboth = true;
else
    showboth = false;
end
%-----------------------------------------------------------------------------------------------------------------
switch numel(mousesetting)
    case 2
        conuse  = currcon;
        conuse  = conuse(mousesetting); % takes care of flipping
        conplot = abs(conuse);
        for imouse = 1:2%mousesetting
            if conuse(imouse)==0
                conuse(imouse) = eps;
            end
            orplot(imouse) = orvec(1 + (sign(conuse(imouse)) + 1)/2, imouse);
        end
        
    case 1
        if showboth
            conplot(:) = abs(currcon);
        else
            conplot(mousesetting) = abs(currcon);
        end
        if currcon==0 % this is to be able to use the sign function when contrast is 0
            currcon = eps;
        end
        orplot = orvec(1 + (sign(currcon) + 1)/2, :);
    case 0
        error('There should be at least one mouse performing. Check settings');
end
%-----------------------------------------------------------------------------------------------------------------
GratingProperties.backgroundOffset      = 0.5 * [1 1 1 0];
GratingProperties.preContrastMultiplier = 0.5;
GratingProperties.contrastplot = conplot;
GratingProperties.orientation  = orplot;
GratingProperties.PhaseStep    = (S.GUI.TemporalFrequency * 360)/ops.screenFs;
GratingProperties.freq         = S.GUI.SpatialFrequency * ops.degPerPixel;
GratingProperties.radius       = S.GUI.StimulusRadius/ops.degPerPixel;
GratingProperties.sigma        = (S.GUI.StimulusRadius/ops.degPerPixel)/2;
GratingProperties.phase        = randn(1, 2)*45; % start with random phase
GratingProperties.issquare     = S.GUI.SquareWave;
%-----------------------------------------------------------------------------------------------------------------
% setup how phase changes
if isequal(orplot, [ops.degPositive ops.degPositive])
    signphase = [1 1];
elseif isequal(orplot, [ops.degPositive ops.degNegative])
    signphase = [1 -1];
elseif isequal(orplot, [ops.degNegative ops.degPositive])
    signphase = [-1 1];
else 
    signphase = [-1 -1];
end
GratingProperties.signphase = signphase;
%-----------------------------------------------------------------------------------------------------------------
% drawing is common for either one or two mice, contrast is zero always for empty mouse
PTB.pulsewindow = PTB.windowrects;
wp = ops.pulseWinWidth;
PTB.pulsewindow(:, 1:2) = PTB.pulsewindow(:, 3:4) - wp;
ww  = ceil(GratingProperties.sigma * 2 * 3);

for ii = 1:2
    if S.GUI.SquareWave 
        [PTB.GaborTexs(ii), PTB.GaborRects(ii, :)] = CreateProceduralSquareWaveGrating(PTB.windows(ii),...
            ww, ww,...
            GratingProperties.backgroundOffset, GratingProperties.radius, GratingProperties.preContrastMultiplier);
    else
        [PTB.GaborTexs(ii), PTB.GaborRects(ii, :)] = CreateProceduralGabor(PTB.windows(ii),...
            ww, ww, 0, GratingProperties.backgroundOffset, 1, GratingProperties.preContrastMultiplier);
%         PTB.GaborTexs(ii) = CreateProceduralSineGrating(PTB.windows(ii),...
%             PTB.windowrects(ii,3)*2, PTB.windowrects(ii,3)*2,...
%             GratingProperties.backgroundOffset, GratingProperties.radius, GratingProperties.preContrastMultiplier);
    end
end
%-----------------------------------------------------------------------------------------------------------------
offset = S.GUI.StimulusOffset;
PTB.xc = zeros(2,1);
PTB.yc = zeros(2,1);

if S.GUI.RandomHeight
    hadd = abs(randn(1)) * PTB.windowrects(ii,4)/4;
else
    hadd = 0;
end

for ii = 1:2
    PTB.xc(ii) = PTB.windowrects(ii,3)/2  - ww/2 - signphase(ii)*round(offset*ww/2) ;
    PTB.yc(ii) = - ww/2 + GratingProperties.sigma * 2 + hadd;
end
%-----------------------------------------------------------------------------------------------------------------
% screen patch update
PTB.idx = 1;
%-----------------------------------------------------------------------------------------------------------------
end
