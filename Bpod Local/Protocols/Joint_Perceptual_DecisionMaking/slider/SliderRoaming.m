function SliderRoaming(~,~)
%PTBDISPLAY Summary of this function goes here

 %----------------------------------------------------------------------
global myStepperBoard sliderProperties;
%----------------------------------------------------------------------
peruse  = sliderProperties.maxspeed/2;
currn   = 0;
currtic = tic;
roamtrialidx = 1 + mod(sliderProperties.iroamtrial - 1, numel(sliderProperties.roamchoices));

%sliderProperties.roamdecsteps(mod(istep, Nstepsavail) + 1)
if sliderProperties.timeonplat < sliderProperties.roamingdectimes(roamtrialidx)
    if sliderProperties.timeonplat == 0
        SendBpodSoftCode(10); % only send soft code at the platform beginning
    end
    % half of the SD when in roaming mode
    if sliderProperties.RoamingType > 1 && sliderProperties.RoamingSD > 0
        roamidx =  1 + mod(sliderProperties.iroam - 1, numel(sliderProperties.roamdecsteps));
        currn   = sliderProperties.roamdecsteps(roamidx);
    end
    myStepperBoard.startMotorRotation(0, currn, peruse);
    waitForMotor(myStepperBoard);
    tel = toc(currtic);
    sliderProperties.timeonplat = sliderProperties.timeonplat + tel;
    sliderProperties.iroam      = sliderProperties.iroam + 1;
    sliderProperties.x          = sliderProperties.x + currn;
else
    SendBpodSoftCode(11);

    sliderchoice = sliderProperties.roamchoices(roamtrialidx);
    if sliderchoice >0
        sidemove = 'r';
    else
        sidemove = 'l';
    end
    
    moveToEndPoint(myStepperBoard, sidemove, sliderProperties.maxspeed, false, round(sliderProperties.endstopdistance*1.1));
%     Nsteps = floor((sliderProperties.endstopdistance - sliderProperties.x) * 0.5);
%     moveToEndPointSteps(myStepperBoard, sidemove, sliderProperties.maxspeed, Nsteps);
    pause(0.3); % no reward time

%     myStepperBoard.startMotorRotation(0, ...
%         -sliderchoice * Nsteps, sliderProperties.roamspeedreturn(roamtrialidx));
    myStepperBoard.startMotorRotation(0, ...
        -sliderchoice * sliderProperties.xpos, sliderProperties.roamspeedreturn(roamtrialidx));
    waitForMotor(myStepperBoard);

    sliderProperties.timeonplat = 0;
    sliderProperties.iroamtrial = sliderProperties.iroamtrial + 1;
    sliderProperties.x          = 0;
end
% disp(sliderProperties.timeonplat)   
end




