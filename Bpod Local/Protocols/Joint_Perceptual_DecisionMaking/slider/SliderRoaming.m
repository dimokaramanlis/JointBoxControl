function SliderRoaming(~,~)
%PTBDISPLAY Summary of this function goes here


global myStepperBoard
%----------------------------------------------------------------------
peruse = 85;
nrand = round(randn(1)*20);
percurr = (0.2+0.8*rand(1))*peruse;
myStepperBoard.startMotorRotation(0, nrand, percurr);
waitForMotor(myStepperBoard);
%----------------------------------------------------------------------
% old code for checking
% switch GratingProperties.orientation
%     case [ops.degPositive ops.degPositive] % M1 Left M2 Right 
%         signphase = [-1 1];
%     case [ops.degPositive ops.degNegative] %Both Right Stimulus
%         signphase = [-1 -1];
%     case [ops.degNegative ops.degPositive] % Both Left (identical to top but separated for friendliness)
%         signphase = [1 1];
%     case [ops.degNegative ops.degNegative] % M1 Right, M2 Left
%         signphase = [1 -1];
% end

        
end




