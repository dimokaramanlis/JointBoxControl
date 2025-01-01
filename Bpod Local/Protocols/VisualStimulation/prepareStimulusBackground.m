function [windows, windowrects] = prepareStimulusBackground(screenIds, invgamma, intensityval)
%UNTITLED Summary of this function goes here

PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
windows     = zeros(numel(screenIds), 1);
windowrects = zeros(numel(screenIds), 4);

for iscreen = 1:numel(screenIds)
    [windows(iscreen), windowrects(iscreen,:)] = PsychImaging('OpenWindow', screenIds(iscreen), 0, []);
    [~, successgamma] = Screen('LoadNormalizedGammaTable', windows(iscreen), invgamma(:,:,iscreen));
end
%lineartable = repmat(linspace(0,1,256)', [1 3 2]);

% go to black
for iscreen = 1:numel(screenIds)
    Screen('FillRect', windows(iscreen), intensityval, windowrects(iscreen,:));
    Screen('Flip', windows(iscreen));
end

end