function [steplengths, steptimes] = measureSliderLength(myStepperBoard, ...
    Nstepsmin, Nstepsmax, Nres, peruse)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

steplengths = round(linspace(Nstepsmin, Nstepsmax, Nres));
steptimes   = zeros(size(steplengths));

 for ilength = 1:numel(steplengths)
    moveToEndPoint(myStepperBoard, 'l', peruse);
    tic;
    myStepperBoard.startMotorRotation(0, steplengths(ilength), peruse);
    waitForMotor(myStepperBoard);
    steptimes(ilength) = toc;
 end

 
end

