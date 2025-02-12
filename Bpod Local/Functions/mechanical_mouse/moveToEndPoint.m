function [valreturn, counter] = moveToEndPoint(myStepperBoard, ptside, peruse, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin < 4
    verbose = true;
else
    verbose = false;
end

Nstepsmax = 3000;
switch ptside
    case {'right', 'r', 'Right'}
        txtwrite = 'right';
        signuse = 1;
    case {'left', 'l', 'Left'}
        txtwrite = 'left';
        signuse = -1;
end
myStepperBoard.startMotorRotation(0, signuse * Nstepsmax, peruse, false);

isRunning = myStepperBoard.isMotorRunning(0);
tic;
while isRunning == true
    isRunning = myStepperBoard.isMotorRunning(0);
end
if verbose
    fprintf('Took %2.2f sec to reach %s endpoint\n', toc, txtwrite)
end
valreturn = ~isRunning;
counter   = toc;
end

