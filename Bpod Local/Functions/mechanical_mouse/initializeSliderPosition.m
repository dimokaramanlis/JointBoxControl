function [myStepperBoard, Nmid] = initializeSliderPosition(sliderinfo, comport)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
peruse = 85;

myStepperBoard = msb2302steppers(comport, 115200, 0x58);
if myStepperBoard.isDeviceReady()

    myStepperBoard.setMotorAcceleration(0,9,13);           % Need to be before config
    myStepperBoard.setMotorConfig(0, 0, 1, 0, 0);
    myStepperBoard.setMotorTopFrequency(0, 180);
    %     moveToEndPoint(myStepperBoard, 'r', peruse);
    moveToEndPoint(myStepperBoard, 'l', peruse);
    Nmid = round(sliderinfo.endstopdistance/2);
    myStepperBoard.startMotorRotation(0, Nmid, peruse, false);
    xstart = Nmid;
end
end