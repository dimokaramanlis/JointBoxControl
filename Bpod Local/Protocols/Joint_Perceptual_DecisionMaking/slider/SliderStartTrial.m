function SliderStartTrial(~,~)
%PTBDISPLAY Summary of this function goes here

global myStepperBoard sliderProperties
%----------------------------------------------------------------------
% we first stop roaming to start deciding
myStepperBoard.stopMotorRotation(0)
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
if sliderProperties.sliderchoice>0
    sidemove = 'r';
else
    sidemove = 'l';
end
%----------------------------------------------------------------------
% first slider goes to spout
moveToEndPoint(myStepperBoard, sidemove, sliderProperties.maxspeed, false);
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
speedreturn =  (1 + rand(1))* sliderProperties.maxspeed/2;
myStepperBoard.startMotorRotation(0, ...
    -sliderProperties.sliderchoice * sliderProperties.xpos, speedreturn);
%----------------------------------------------------------------------

        
end




