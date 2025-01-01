function NaturalisticWavesStimulusFunction()

global PTB StimPara
wp = 50;
meanifi    = mean(PTB.ifis);

Priority(1);

for iscreen = 1:numel(PTB.windows)
    Screen('FillRect', PTB.windows(iscreen), 0.5, PTB.windowrects(iscreen,:));
    Screen('FillRect', PTB.windows(iscreen), 0, ...
        [PTB.windowrects(iscreen,3:4)-wp PTB.windowrects(iscreen, 3:4)]);
end
for iscreen = 1:numel(PTB.windows)
    PTB.vbls(iscreen) = Screen('Flip', PTB.windows(iscreen), PTB.vbls(iscreen) + 0.5*meanifi);
end

StimPara.currstimid = StimPara.currstimid + 1;
for framecount = 1:StimPara.Nstimframes
    for iscreen = 1:numel(PTB.windows)
        Screen('DrawTexture', PTB.windows(iscreen), ...
            PTB.textureIndex(framecount, StimPara.randorder(StimPara.currstimid), iscreen));
         Screen('FillRect', PTB.windows(iscreen), double(framecount<4), ...
            [PTB.windowrects(iscreen,3:4)-wp PTB.windowrects(iscreen, 3:4)]);
    end

    for iscreen = 1:numel(PTB.windows)
        PTB.vbls(iscreen) = Screen('Flip', PTB.windows(iscreen), PTB.vbls(iscreen) + 0.5*meanifi);
    end
end

for framecount = 1:StimPara.Ngrayframes
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
