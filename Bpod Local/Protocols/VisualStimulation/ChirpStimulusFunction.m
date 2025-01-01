function ChirpStimulusFunction()

global PTB StimPara
chrptrace  = StimPara.chrptrace;
meanifi    = mean(PTB.ifis);
wp = 50;

Priority(1);

for iscreen = 1:numel(PTB.windows)
    Screen('FillRect', PTB.windows(iscreen), 0, PTB.windowrects(iscreen,:));
    Screen('FillRect', PTB.windows(iscreen), 0, ...
        [PTB.windowrects(iscreen,3:4)-wp PTB.windowrects(iscreen, 3:4)]);
end
for iscreen = 1:numel(PTB.windows)
    PTB.vbls(iscreen) = Screen('Flip', PTB.windows(iscreen), PTB.vbls(iscreen) + 0.5*meanifi);
end


for framecount = 1:numel(chrptrace)
    for iscreen = 1:numel(PTB.windows)
        Screen('FillRect', PTB.windows(iscreen), chrptrace(framecount), PTB.windowrects(iscreen,:));
        Screen('FillRect', PTB.windows(iscreen), StimPara.pulsetrace(framecount), ...
            [PTB.windowrects(iscreen,3:4)-wp PTB.windowrects(iscreen, 3:4)]);
    end
    for iscreen = 1:numel(PTB.windows)
        PTB.vbls(iscreen) = Screen('Flip', PTB.windows(iscreen), PTB.vbls(iscreen) +  0.5*meanifi);
    end
end
Priority(0);
  

end
