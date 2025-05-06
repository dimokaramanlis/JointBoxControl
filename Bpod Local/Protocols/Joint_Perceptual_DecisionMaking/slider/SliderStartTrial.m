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
sliderProperties.decsteps = sliderProperties.decsteps(1:istep-1);
%----------------------------------------------------------------------
% first slider goes to spout with max speed
moveToEndPoint(myStepperBoard, sliderProperties.sidemove, ...
    sliderProperties.maxspeed, false, round(sliderProperties.endstopdistance*1.1));
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




