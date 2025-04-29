function SliderStartTrial(~,~)
%PTBDISPLAY Summary of this function goes here

global myStepperBoard sliderProperties;
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
% first slider goes to spout with max speed
moveToEndPoint(myStepperBoard, sliderProperties.sidemove, sliderProperties.maxspeed, false);
% Nsteps = floor(abs(sliderProperties.endval - x) * 0.99);
% moveToEndPointSteps(myStepperBoard, sliderProperties.sidemove,...
%     sliderProperties.maxspeed, Nsteps);
% xfin = x + sliderProperties.sliderchoice * Nsteps;
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
% myStepperBoard.startMotorRotation(0, ...
%     -(xfin -  sliderProperties.xpos), sliderProperties.speedreturn);
%----------------------------------------------------------------------
end




