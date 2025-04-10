function SliderRoaming(~,~)
%PTBDISPLAY Summary of this function goes here

 
global myStepperBoard sliderProperties
%----------------------------------------------------------------------
peruse = sliderProperties.maxspeed;
nrand  = round(randn(1)*sliderProperties.UncertaintySD);
percurr = peruse; %(0.2+0.8*rand(1))*peruse;
myStepperBoard.startMotorRotation(0, nrand, percurr);
waitForMotor(myStepperBoard);
%----------------------------------------------------------------------

        
end




