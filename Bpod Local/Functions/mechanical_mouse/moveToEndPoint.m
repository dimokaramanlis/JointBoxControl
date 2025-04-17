function [valreturn, counter] = moveToEndPoint(myStepperBoard, ptside, peruse, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin < 4
    verbose = true;
else
    verbose = varargin{1};
end

if nargin < 5
	Nstepsmax = 3000;
else
	Nstepsmax = varargin{2};
end

switch ptside
    case {'right', 'r', 'Right'}
        txtwrite = 'right';
        signuse = 1;
    case {'left', 'l', 'Left'}
        txtwrite = 'left';
        signuse = -1;
end
myStepperBoard.startMotorRotation(0, signuse * Nstepsmax, peruse, false);

currtimer = tic;
waitForMotor(myStepperBoard);
if verbose
    fprintf('Took %2.2f sec to reach %s endpoint\n', toc, txtwrite)
end
valreturn = true;
counter   = toc(currtimer);

end

