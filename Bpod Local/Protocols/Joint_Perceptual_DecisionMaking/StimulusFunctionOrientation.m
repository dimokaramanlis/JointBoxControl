function StimulusFunctionOrientation(ID)
%--------------------------------------------------------------------------
global PTB S ops displayTimer sliderTimer myStepperBoard;

%--------------------------------------------------------------------------
switch ID
    %------------------------------------------------------------------
    case 101
        Priority(1);
        
        for iscreen = 1:2
            Screen('FillRect',PTB.windows(iscreen), PTB.grey, ...
                 [0 0 PTB.windowrects(iscreen,3) PTB.windowrects(iscreen,4)]);
            Screen('FillRect', PTB.windows(iscreen), 0, PTB.pulsewindow(iscreen,:));
        end
        for iscreen = 1:2
           Screen('Flip', PTB.windows(iscreen)); 
        end

        % make sure slider is back home
        if ops.useSlider > 0
            waitForMotor(myStepperBoard);
%             SendBpodSoftCode(10);

            sliderTimer = timer;
            sliderTimer.stop();
            sliderTimer.Period         = 0.01; %10ms refresh
            sliderTimer.TimerFcn       = @SliderRoaming;
            sliderTimer.StopFcn        = @SliderRoamingStop;
            sliderTimer.ExecutionMode  = 'fixedSpacing';
            sliderTimer.TasksToExecute = 10000;
            sliderTimer.start();
        end
    %------------------------------------------------------------------
    case 10 % Flip screen and progress phase
        %------------------------------------------------------------------
    case 100 %Stop and gray screen
        %------------------------------------------------------------------
         if ~isempty(displayTimer.StopFcn)
           displayTimer.stop();
           displayTimer.Period = round(1/ops.screenFs, 3); %10ms refresh
         end
        %------------------------------------------------------------------
    case 200 %Stop and black screen
        %------------------------------------------------------------------
        if ~isempty(displayTimer.StopFcn)
            displayTimer.stop();
        end
        for iscreen = 1:2
            Screen('FillRect',PTB.windows(iscreen), PTB.black,...
                [0 0 PTB.windowrects(iscreen,3) PTB.windowrects(iscreen,4)]);
            Screen('FillRect', PTB.windows(iscreen), 0, PTB.pulsewindow(iscreen,:));
        end
        for iscreen = 1:2
           Screen('Flip', PTB.windows(iscreen)); 
        end
        %------------------------------------------------------------------
end

if ID == 10
   displayTimer = timer;
   displayTimer.stop();
   displayTimer.Period        = round(1/ops.screenFs, 3); %10ms refresh
   displayTimer.TimerFcn      = @PTBDisplayOrientation;
   displayTimer.ExecutionMode = 'fixedRate';
   displayTimer.StopFcn       = {@PTBDisplayOrientationNeutral};
   if S.GUI.StimulusDuration >0
       displayTimer.TasksToExecute = round(S.GUI.StimulusDuration/displayTimer.Period);
       displayTimer.start();
   else
       displayTimer.TasksToExecute = 1;
   end 
   %-----------------------------------------------------------------------
   % start slider if needed
   if ops.useSlider > 0
%        SliderRoamingStop();
% 
        sliderTimer.stop();
        SliderStartTrial();
   end
   %-----------------------------------------------------------------------
end

end