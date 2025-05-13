function SliderRoaming(~,~)
%PTBDISPLAY Summary of this function goes here

 %----------------------------------------------------------------------
global myStepperBoard sliderProperties;
%----------------------------------------------------------------------
if sliderProperties.iroamtrial<numel(sliderProperties.roamdecsteps)+1 ...
        && ~myStepperBoard.isMotorRunning(0)

    stepscurr    = sliderProperties.roamdecsteps{sliderProperties.iroamtrial};
    peruse       = sliderProperties.roamspeeds{sliderProperties.iroamtrial};

    myStepperBoard.startMotorRotation(0, ...
        stepscurr(sliderProperties.iroamstep), peruse(sliderProperties.iroamstep));
    
    % move to next trial
    sliderProperties.iroamstep = sliderProperties.iroamstep + 1;
    if sliderProperties.iroamstep > numel(sliderProperties.roamdecsteps{sliderProperties.iroamtrial})
        sliderProperties.iroamtrial = sliderProperties.iroamtrial + 1;
        sliderProperties.iroamstep  = 1;
    end
end
%----------------------------------------------------------------------

%----------------------------------------------------------------------

end




