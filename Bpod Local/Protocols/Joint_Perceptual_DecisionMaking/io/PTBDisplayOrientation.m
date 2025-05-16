function PTBDisplayOrientation(~,~)
%PTBDISPLAY Summary of this function goes here


global PTB GratingProperties
%----------------------------------------------------------------------
for iscreen = 1:2
%     dstRect = CenterRectOnPoint(Screen('Rect', PTB.GaborTexs(iscreen)), PTB.xc(iscreen), PTB.yc(iscreen));
% Screen('DrawTextures', PTB.windows(iscreen), PTB.GaborTexs(iscreen), [], [],...
%         GratingProperties.orientation(iscreen), [], [], [], [],...
%         [], gratingprops');
    if GratingProperties.issquare
        gratingprops = [GratingProperties.phase(iscreen), GratingProperties.freq,...
            GratingProperties.contrastplot(iscreen), 0];
        torotate = [];
    else
        gratingprops = [GratingProperties.phase(iscreen), GratingProperties.freq, GratingProperties.sigma,...
            GratingProperties.contrastplot(iscreen), 1, 0, 0, 0];
        torotate = kPsychDontDoRotation;
    end
    dstRect = OffsetRect(PTB.GaborRects(iscreen, :), PTB.xc(iscreen), PTB.yc(iscreen));

    Screen('DrawTexture', PTB.windows(iscreen), PTB.GaborTexs(iscreen), [], dstRect,...
        GratingProperties.orientation(iscreen), [], [], [], [],...
        torotate, gratingprops');

    % draw patch
    Screen('FillRect', PTB.windows(iscreen), double(PTB.idx<4), PTB.pulsewindow(iscreen,:));
end

% advance phase
GratingProperties.phase = GratingProperties.phase + GratingProperties.signphase * GratingProperties.PhaseStep;
PTB.idx = PTB.idx + 1;

% draw
for iscreen = 1:2
    Screen('Flip', PTB.windows(iscreen));
end

%----------------------------------------------------------------------
        
end




