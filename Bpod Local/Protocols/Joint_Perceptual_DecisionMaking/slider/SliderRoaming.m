function SliderRoaming(~,~)
%PTBDISPLAY Summary of this function goes here

 
global myStepperBoard sliderProperties
%----------------------------------------------------------------------
peruse  = sliderProperties.maxspeed/2;
currn   = 0;
% half of the SD when in roaming mode
if sliderProperties.RoamingType > 1
    if sliderProperties.RoamingSD > 0
        nrand   = sliderProperties.RoamingSD;
        currn   = randn(1);
        currn   = -sign(sliderProperties.trajx) * max(abs(round(nrand * currn)),1);
    end
end
sliderProperties.trajx = currn;
percurr = peruse; %(0.2+0.8*rand(1))*peruse;

myStepperBoard.startMotorRotation(0, currn, percurr);
waitForMotor(myStepperBoard);
%----------------------------------------------------------------------

        
end




