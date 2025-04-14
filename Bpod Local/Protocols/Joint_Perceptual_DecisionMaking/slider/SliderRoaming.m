function SliderRoaming(~,~)
%PTBDISPLAY Summary of this function goes here

 %----------------------------------------------------------------------
global myStepperBoard sliderProperties S
%----------------------------------------------------------------------
peruse  = sliderProperties.maxspeed/2;
currn   = 0;
currtic = tic;
if sliderProperties.timeonplat < sliderProperties.currwait
    if sliderProperties.timeonplat == 0
        SendBpodSoftCode(10); % only send soft code at the platform beginning
    end
    % half of the SD when in roaming mode
    if sliderProperties.RoamingType > 1
        if sliderProperties.RoamingSD > 0
            nrand   = sliderProperties.RoamingSD;
            currn   = randn(1);
            currn   = -sign(sliderProperties.trajx) * max(abs(round(nrand * currn)),1);
        end
    end
    sliderProperties.trajx = currn;    
    myStepperBoard.startMotorRotation(0, currn, peruse);
    waitForMotor(myStepperBoard);
    tel = toc(currtic);
    sliderProperties.timeonplat = sliderProperties.timeonplat + tel;
else
    SendBpodSoftCode(11);

    sliderchoice = 2*(rand(1) > 0.5) - 1;
    if sliderchoice>0
        sidemove = 'r';
    else
        sidemove = 'l';
    end
    newaittime = exprnd(3 * S.GUI.DTimeAvg);
    moveToEndPoint(myStepperBoard, sidemove, sliderProperties.maxspeed, false);
    pause(0.3);
    speedreturn =  (1 + rand(1))* sliderProperties.maxspeed/2;
    myStepperBoard.startMotorRotation(0, ...
        -sliderchoice * sliderProperties.xpos, speedreturn);
    waitForMotor(myStepperBoard);
    sliderProperties.timeonplat = 0;
    sliderProperties.currwait   = newaittime;
end
% disp(sliderProperties.timeonplat)   
end




