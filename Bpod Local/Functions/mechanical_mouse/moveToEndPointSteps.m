function valreturn = moveToEndPointSteps(myStepperBoard, ptside, peruse, Nstepsmax)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


switch ptside
    case {'right', 'r', 'Right'}
        signuse = 1;
    case {'left', 'l', 'Left'}
        signuse = -1;
end
myStepperBoard.startMotorRotation(0, signuse * Nstepsmax, peruse, false);

isRunning = myStepperBoard.isMotorRunning(0);
while isRunning == true
    isRunning = myStepperBoard.isMotorRunning(0);
end
valreturn = ~isRunning;
end

