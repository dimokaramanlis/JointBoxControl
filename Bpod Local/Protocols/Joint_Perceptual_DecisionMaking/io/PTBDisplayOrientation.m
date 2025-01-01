function PTBDisplayOrientation(~,~)
%PTBDISPLAY Summary of this function goes here


global PTB GratingProperties
%----------------------------------------------------------------------
for iscreen = 1:2

% 
%     dstRect = CenterRectOnPoint(Screen('Rect', PTB.GaborTexs(iscreen)), PTB.xc(iscreen), PTB.yc(iscreen));
% Screen('DrawTextures', PTB.windows(iscreen), PTB.GaborTexs(iscreen), [], [],...
%         GratingProperties.orientation(iscreen), [], [], [], [],...
%         [], gratingprops');
    if GratingProperties.issquare
        gratingprops = [GratingProperties.phase(iscreen), GratingProperties.freq,...
            GratingProperties.contrastplot(iscreen), 0];
    else
        gratingprops = [GratingProperties.phase(iscreen), GratingProperties.freq, GratingProperties.sigma,...
            GratingProperties.contrastplot(iscreen), 1, 0, 0, 0];
    end
    dstRect = OffsetRect(PTB.GaborRects(iscreen, :), PTB.xc(iscreen), PTB.yc(iscreen));

    Screen('DrawTexture', PTB.windows(iscreen), PTB.GaborTexs(iscreen), [], dstRect,...
        GratingProperties.orientation(iscreen), [], [], [], [],...
        kPsychDontDoRotation, gratingprops');

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
% old code for checking
% switch GratingProperties.orientation
%     case [ops.degPositive ops.degPositive] % M1 Left M2 Right 
%         signphase = [-1 1];
%     case [ops.degPositive ops.degNegative] %Both Right Stimulus
%         signphase = [-1 -1];
%     case [ops.degNegative ops.degPositive] % Both Left (identical to top but separated for friendliness)
%         signphase = [1 1];
%     case [ops.degNegative ops.degNegative] % M1 Right, M2 Left
%         signphase = [1 -1];
% end

        
end




