function SliderStartTrial(~,~)
%PTBDISPLAY Summary of this function goes here

global myStepperBoard sliderProperties;
%----------------------------------------------------------------------
myStepperBoard.stopMotorRotation(0);

for istep = 1:numel(sliderProperties.decsteps)
    myStepperBoard.startMotorRotation(0, ...
        sliderProperties.decsteps(istep), sliderProperties.maxspeed);
    waitForMotor(myStepperBoard);
end

% SendBpodSoftCode(11);
%----------------------------------------------------------------------
% first slider goes to spout with max speed
moveToEndPoint(myStepperBoard, sliderProperties.sidemove, sliderProperties.maxspeed, ...
    false, ceil(sliderProperties.endstopdistance*0.6));
% Nsteps = floor(abs(sliderProperties.endval - x) * 0.99);
% moveToEndPointSteps(myStepperBoard, sliderProperties.sidemove,...
%     sliderProperties.maxspeed, Nsteps);
% xfin = x + sliderProperties.sliderchoice * Nsteps;
%----------------------------------------------------------------------
% then slider waits based on outcome.
% to increase robustness, we poke three times
if sliderProperties.outcome > 0
	softcode = 1;
else
	softcode = 2;
end

for ii = 1:3
    SendBpodSoftCode(softcode); % whenever the slider reaches the spout, state machine gets to know
	pause(sliderProperties.spouttime/3);
end
% stay to drink or stay for a bit on the spout
%----------------------------------------------------------------------
% finally, slider goes back to the center
myStepperBoard.startMotorRotation(0, ...
    -sliderProperties.sliderchoice * sliderProperties.xpos, sliderProperties.speedreturn);
% myStepperBoard.startMotorRotation(0, ...
%     -(xfin -  sliderProperties.xpos), sliderProperties.speedreturn);
%----------------------------------------------------------------------
end




