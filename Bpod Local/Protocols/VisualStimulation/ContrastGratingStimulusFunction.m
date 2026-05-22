function ContrastGratingStimulusFunction()

global PTB StimPara
wp = 50;
meanifi    = mean(PTB.ifis);

Priority(1);
degPerPixel   = 92/1280;

GratingProperties.backgroundOffset      = 0.5 * [1 1 1 0];
GratingProperties.preContrastMultiplier = 0.5;
GratingProperties.orientation        = StimPara.orientation;
GratingProperties.freq               = StimPara.SpatialFrequency * degPerPixel;
GratingProperties.radius             = StimPara.StimulusRadius/degPerPixel;
GratingProperties.sigma              = (StimPara.StimulusRadius/degPerPixel)/2;
GratingProperties.phase              = randn(1, 2)*45; % start with random phase


for iscreen = 1:numel(PTB.windows)
    Screen('FillRect', PTB.windows(iscreen), 0.5, PTB.windowrects(iscreen,:));
    Screen('FillRect', PTB.windows(iscreen), 0, ...
        [PTB.windowrects(iscreen,3:4)-wp PTB.windowrects(iscreen, 3:4)]);
end
for iscreen = 1:numel(PTB.windows)
    PTB.vbls(iscreen) = Screen('Flip', PTB.windows(iscreen), PTB.vbls(iscreen) + 0.5*meanifi);
end

PTB.pulsewindow = PTB.windowrects;
PTB.pulsewindow(:, 1:2) = PTB.pulsewindow(:, 3:4) - wp;
ww  = ceil(GratingProperties.sigma * 2 * 3);


for ii = 1:2
    [PTB.GaborTexs(ii), PTB.GaborRects(ii, :)] = CreateProceduralGabor(PTB.windows(ii),...
        ww, ww, 0, GratingProperties.backgroundOffset, 1, GratingProperties.preContrastMultiplier);
end

    torotate = kPsychDontDoRotation;
    
    
offset = StimPara.StimulusOffset;
PTB.xc = zeros(2,1);
PTB.yc = zeros(2,1);


        
StimPara.currstimid = StimPara.currstimid + 1;
stimid              = StimPara.randorder(StimPara.currstimid);
currcon             = StimPara.contrasts(stimid);

signphase = [1, -1] * sign(currcon);
for ii = 1:2
    PTB.xc(ii) = PTB.windowrects(ii,3)/2  - ww/2 - signphase(ii)*round(offset*ww/2) ;
    PTB.yc(ii) = - ww/2 + GratingProperties.sigma * 2;
end


for framecount = 1:StimPara.Nstimframes
    
    for iscreen = 1:numel(PTB.windows)
        gratingprops = [GratingProperties.phase(iscreen), GratingProperties.freq, GratingProperties.sigma,...
            abs(currcon), 1, 0, 0, 0];
        dstRect = OffsetRect(PTB.GaborRects(iscreen, :), PTB.xc(iscreen), PTB.yc(iscreen));

        Screen('DrawTexture', PTB.windows(iscreen), PTB.GaborTexs(iscreen), [], dstRect,...
            GratingProperties.orientation, [], [], [], [],...
            torotate, gratingprops');
        
        Screen('FillRect', PTB.windows(iscreen), double(framecount<4), ...
            [PTB.windowrects(iscreen,3:4)-wp PTB.windowrects(iscreen, 3:4)]);
    end

    for iscreen = 1:numel(PTB.windows)
        PTB.vbls(iscreen) = Screen('Flip', PTB.windows(iscreen), PTB.vbls(iscreen) + 0.5*meanifi);
    end
end

for framecount = 1:StimPara.randgray(StimPara.currstimid)
    for iscreen = 1:numel(PTB.windows)
        Screen('FillRect', PTB.windows(iscreen), 0.5, PTB.windowrects(iscreen,:));
        Screen('FillRect', PTB.windows(iscreen), double(framecount<4), ...
            [PTB.windowrects(iscreen,3:4)-wp PTB.windowrects(iscreen, 3:4)]);
    end
    for iscreen = 1:numel(PTB.windows)
        PTB.vbls(iscreen) = Screen('Flip', PTB.windows(iscreen), PTB.vbls(iscreen) + 0.5*meanifi);
    end

end
Priority(0);

end
