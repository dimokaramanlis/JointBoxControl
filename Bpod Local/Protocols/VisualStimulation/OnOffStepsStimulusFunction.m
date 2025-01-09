function OnOffStepsStimulusFunction()

global PTB StimPara
meanifi    = mean(PTB.ifis);
wp = 50;

Priority(1);

% for iscreen = 1:numel(PTB.windows)
%     Screen('FillRect', PTB.windows(iscreen), 0, PTB.windowrects(iscreen,:));
%     Screen('FillRect', PTB.windows(iscreen), 0, ...
%         [PTB.windowrects(iscreen,3:4)-wp PTB.windowrects(iscreen, 3:4)]);
% end
% for iscreen = 1:numel(PTB.windows)
%     PTB.vbls(iscreen) = Screen('Flip', PTB.windows(iscreen), PTB.vbls(iscreen) + 0.5*meanifi);
% end

consuse = [1 0];
for icon = 1:2
    for framecount = 1:StimPara.Nstimframes
        for iscreen = 1:numel(PTB.windows)
            Screen('FillRect', PTB.windows(iscreen), consuse(icon), PTB.windowrects(iscreen,:));
            Screen('FillRect', PTB.windows(iscreen), double(framecount<4), ...
                [PTB.windowrects(iscreen,3:4)-wp PTB.windowrects(iscreen, 3:4)]);
        end
        for iscreen = 1:numel(PTB.windows)
            PTB.vbls(iscreen) = Screen('Flip', PTB.windows(iscreen), PTB.vbls(iscreen) +  0.5*meanifi);
        end
    end
end
Priority(0);
  

end
