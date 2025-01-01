% Main program

% Initialiser la classe msb2302netbox pour ouvrir le port série
%gateway = msb2302gateway("COM18", 115200);

% Obtenir le handler du port série
%serialHandler = gateway.getSerialHandler();

% Initialiser une autre classe en passant le handler
%myStepperBoard = msb2302steppers(serialHandler, 0x58);
%myStepperBoard2 = msb2302steppers(serialHandler, 0x59);

serialportlist("available")
myStepperBoard = msb2302steppers("COM3", 115200, 0x58);

if myStepperBoard.isDeviceReady()
    disp('[MAIN] ----> Board ready ');
    %motorNb, AccelRampEnable, EndStopsEnable, CWbreakEnable, CCWbreakEnable

    myStepperBoard.setMotorAcceleration(0,9,13);           % Need to be before config
    myStepperBoard.setMotorConfig(0, 0, 1, 0, 0);
    

%     while true
%         [P0, P1] = myStepperBoard.isEndStopsActive(0);
%         pause(0.5);
%     end    
    i = 0;
    topFreq = 200;
    while i < 5
        topFreq = topFreq + 20;
        disp(sprintf('Set New top frequency to: %d Hz', topFreq));
        myStepperBoard.setMotorTopFrequency(0, topFreq);
        myStepperBoard.startMotorRotation(0, 1250, 100);
        isRunning = myStepperBoard.isMotorRunning(0);
        disp('Waiting for motor stop...');
        while isRunning == true
            isRunning = myStepperBoard.isMotorRunning(0);
            pause(0.1);
        end
        pause(0.2);

        myStepperBoard.startMotorRotation(0, -1250, 100);
        isRunning = myStepperBoard.isMotorRunning(0);
        disp('Waiting for motor stop...');
        while isRunning == true
            isRunning = myStepperBoard.isMotorRunning(0);
            pause(0.1);
        end
        pause(0.2);        

        i = i +1;
    end

   

else
    disp('[MAIN] ----> Unavailable board');
end



% Lorsque le programme se termine, fermer le port série proprement
myStepperBoard.close();