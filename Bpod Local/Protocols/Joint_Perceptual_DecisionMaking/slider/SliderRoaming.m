function SliderRoaming(~,~)
%PTBDISPLAY Summary of this function goes here

 %----------------------------------------------------------------------
global myStepperBoard sliderProperties;
%----------------------------------------------------------------------
waitForMotor(myStepperBoard);
roamtrialidx = 1 + mod(sliderProperties.iroamtrial - 1, numel(sliderProperties.roamdecsteps));
stepscurr    = sliderProperties.roamdecsteps{roamtrialidx};
peruse       = sliderProperties.roamspeeds{roamtrialidx};


fprintf('Starting roaming movement, trial %d, step %d\n...', ...
    roamtrialidx, sliderProperties.iroamstep)
myStepperBoard.startMotorRotation(0, ...
    stepscurr(sliderProperties.iroamstep), peruse(sliderProperties.iroamstep));
% fprintf('roam trial: %d, step: %d\n',roamtrialidx, stepscurr(sliderProperties.iroamstep))
sliderProperties.iroamstep = sliderProperties.iroamstep + 1;
% if sliderProperties.iroamstep > Ndec
%    SendBpodSoftCode(11);
% else
%     SendBpodSoftCode(10);
% end
% move to next trial
if sliderProperties.iroamstep > numel(sliderProperties.roamdecsteps{roamtrialidx})
    sliderProperties.iroamtrial = sliderProperties.iroamtrial + 1;
    sliderProperties.iroamstep  = 1;
end

end




