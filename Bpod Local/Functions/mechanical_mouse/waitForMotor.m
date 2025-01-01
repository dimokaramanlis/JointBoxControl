function waitForMotor(myStepperBoard)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
isRunning = myStepperBoard.isMotorRunning(0);
while isRunning 
   isRunning = myStepperBoard.isMotorRunning(0);
end
end

