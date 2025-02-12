function SliderStartTrial(~,~)
%PTBDISPLAY Summary of this function goes here

global myStepperBoard GratingProperties sliderProperties
%----------------------------------------------------------------------
peruse = 85;
x = 0;
for ii = 1:20
    nrand = round(randn(1)*20);
    percurr = (0.2+0.8*rand(1))*peruse;
    myStepperBoard.startMotorRotation(0, nrand, percurr);
    waitForMotor(myStepperBoard);
    x = x + nrand;
end
%----------------------------------------------------------------------

% if slider is correct, pause for 2 sec, otherwise pause for 0.5 sec
if GratingProperties.orientation(1)>0
    moveToEndPoint(myStepperBoard, 'r', 50)
    pause(1);
    myStepperBoard.startMotorRotation(0, -sliderProperties.xpos, 50);
else
    moveToEndPoint(myStepperBoard, 'l', 50)
    pause(1);
    myStepperBoard.startMotorRotation(0, sliderProperties.xpos, 50);
end
%----------------------------------------------------------------------

        
end




