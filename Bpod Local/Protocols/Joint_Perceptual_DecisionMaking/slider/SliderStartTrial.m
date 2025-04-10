function SliderStartTrial(~,~)
%PTBDISPLAY Summary of this function goes here

global myStepperBoard sliderProperties
%----------------------------------------------------------------------
% we first stop roaming to start deciding
myStepperBoard.stopMotorRotation(0)
%----------------------------------------------------------------------
peruse = sliderProperties.maxspeed;
tic;
tel = 0;
x   = sliderProperties.xpos;
while tel < sliderProperties.dectime
    pause(sliderProperties.dectime*0.2)
    nrand = round(randn(1)*sliderProperties.UncertaintySD);
%     percurr = (0.2+0.8*rand(1))*peruse;
    percurr = peruse;
    myStepperBoard.startMotorRotation(0, nrand, percurr);
    waitForMotor(myStepperBoard);
    x   = x + nrand;
    tel = toc;
end
SendBpodSoftCode(11);
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
% Nsteps = floor((2*sliderProperties.xpos - x) * 0.99);
% moveToEndPointSteps(myStepperBoard, sidemove, sliderProperties.maxspeed, Nsteps);

%----------------------------------------------------------------------
% then slider waits based on outcome
if sliderProperties.outcome > 0
    spouttime = sliderProperties.rewstay;
    % whenever the slider reaches the spout, state machine gets to know
    SendBpodSoftCode(1); 
else
    spouttime = 0.3;
    % whenever the slider reaches the spout, state machine gets to know
    SendBpodSoftCode(2); 
end
% stay to drink or stay for a bit on the spout
pause(spouttime);
%----------------------------------------------------------------------
% finally, slider goes back to the center
speedreturn =  (1 + rand(1))* sliderProperties.maxspeed/2;
myStepperBoard.startMotorRotation(0, ...
    -sliderProperties.sliderchoice * sliderProperties.xpos, speedreturn);
%----------------------------------------------------------------------        
end




