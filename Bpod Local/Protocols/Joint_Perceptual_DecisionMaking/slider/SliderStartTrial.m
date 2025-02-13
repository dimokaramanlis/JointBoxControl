function SliderStartTrial(~,~)
%PTBDISPLAY Summary of this function goes here

global myStepperBoard sliderProperties
%----------------------------------------------------------------------
peruse = sliderProperties.maxspeed/2;
tic;
tel = 0;
x = sliderProperties.xpos;
while tel < sliderProperties.dectime

    nrand = round(randn(1)*20);
%     percurr = (0.2+0.8*rand(1))*peruse;
    percurr = peruse;
    myStepperBoard.startMotorRotation(0, nrand, percurr);
    waitForMotor(myStepperBoard);
    x   = x + nrand;
    tel = toc;
end
%----------------------------------------------------------------------

% if slider is correct, pause for 2 sec, otherwise pause for 0.5 sec
if sliderProperties.rewside>0
    sidemove = 'r';
else
    sidemove = 'l';
end
%----------------------------------------------------------------------
% first slider goes to spout
moveToEndPoint(myStepperBoard, sidemove, sliderProperties.maxspeed);
%----------------------------------------------------------------------
% then slider waits based on outcome
if sliderProperties.outcome
    spouttime = sliderProperties.rewstay;
else
    spouttime = 0.5;
end
pause(spouttime);
%----------------------------------------------------------------------
% finally, slider goes back to the center
myStepperBoard.startMotorRotation(0, -sliderProperties.rewside * sliderProperties.xpos, 50);
%----------------------------------------------------------------------

        
end




