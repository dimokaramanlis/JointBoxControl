function SliderStartTrial(~,~)
%PTBDISPLAY Summary of this function goes here

global myStepperBoard sliderProperties sliderTimer;
%----------------------------------------------------------------------
timeelapsed    = 0;
x              = sliderProperties.xpos;
dectic         = tic;
istep          = 1;
while timeelapsed < sliderProperties.dectime
    myStepperBoard.startMotorRotation(0, sliderProperties.decsteps(istep), sliderProperties.maxspeed);
    waitForMotor(myStepperBoard);
    x           = x + sliderProperties.decsteps(istep);
	istep       = istep + 1;
    timeelapsed = toc(dectic);
end
SendBpodSoftCode(11);
sliderProperties.decsteps = sliderProperties.decsteps(1:istep-1);
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
    % whenever the slider reaches the spout, state machine gets to know
    SendBpodSoftCode(1); 
else
    % whenever the slider reaches the spout, state machine gets to know
    SendBpodSoftCode(2); 
end
% stay to drink or stay for a bit on the spout
pause(sliderProperties.spouttime);
%----------------------------------------------------------------------
% finally, slider goes back to the center
myStepperBoard.startMotorRotation(0, ...
    -sliderProperties.sliderchoice * sliderProperties.xpos, sliderProperties.speedreturn);
%----------------------------------------------------------------------
end




