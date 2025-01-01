function [valreturn, counter] = moveToEndPoint(myStepperBoard, ptside, peruse)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


Nstepsmax = 3000;
switch ptside
    case {'right', 'r', 'Right'}
        txtwrite = 'right';
        signuse = 1;
    case {'left', 'l', 'Left'}
        txtwrite = 'left';
        signuse = -1;
end
myStepperBoard.startMotorRotation(0, signuse * Nstepsmax, peruse);

isRunning = myStepperBoard.isMotorRunning(0);
tic;
while isRunning == true
    isRunning = myStepperBoard.isMotorRunning(0);
end
fprintf('Took %2.2f sec to reach %s endpoint\n', toc, txtwrite)
valreturn = ~isRunning;
counter   = toc;
end

