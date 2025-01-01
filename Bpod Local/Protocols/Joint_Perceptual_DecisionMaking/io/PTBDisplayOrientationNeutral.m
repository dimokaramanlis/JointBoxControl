function PTBDisplayOrientationNeutral(~,~)
global PTB 


for iscreen = 1:2
    Screen('FillRect',PTB.windows(iscreen),PTB.grey,[0 0 PTB.windowrects(iscreen,3) PTB.windowrects(iscreen,4)]);
    Screen('FillRect', PTB.windows(iscreen), 0, PTB.pulsewindow(iscreen,:));
end

for iscreen = 1:2
   Screen('Flip', PTB.windows(iscreen)); 
end

end

