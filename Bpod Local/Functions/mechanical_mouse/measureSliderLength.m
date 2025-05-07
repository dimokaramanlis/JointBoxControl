function steptimes = measureSliderLength(myStepperBoard, steplengths, peruse)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

steptimes   = zeros(size(steplengths));

 for ilength = 1:numel(steplengths)
    moveToEndPoint(myStepperBoard, 'l', peruse, false);
    tic;
    myStepperBoard.startMotorRotation(0, steplengths(ilength), peruse, false);
    waitForMotor(myStepperBoard);
    steptimes(ilength) = toc;
 end

 
end

