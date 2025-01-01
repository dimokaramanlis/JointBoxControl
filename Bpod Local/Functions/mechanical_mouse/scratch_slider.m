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

allpercent = [20 40 60 80 100];
Nsteps = 100;
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
    myStepperBoard.setMotorTopFrequency(0, topFreq);
    for ii = 1:numel(allpercent)
        myStepperBoard.startMotorRotation(0, Nsteps, allpercent(ii));
        isRunning = myStepperBoard.isMotorRunning(0);
        disp('Waiting for motor stop...');
        while isRunning == true
            isRunning = myStepperBoard.isMotorRunning(0);
            pause(0.1);
        end
        pause(0.2);

        myStepperBoard.startMotorRotation(0, -(Nsteps+50), allpercent(ii));
        isRunning = myStepperBoard.isMotorRunning(0);
        disp('Waiting for motor stop...');
        while isRunning == true
            isRunning = myStepperBoard.isMotorRunning(0);
            pause(0.1);
        end
        pause(0.2);        

    end

   

else
    disp('[MAIN] ----> Unavailable board');
end



% Lorsque le programme se termine, fermer le port série proprement
myStepperBoard.close();

%%
% negative is moving leftwards
myStepperBoard = msb2302steppers("COM3", 115200, 0x58);
Nstepsend      = 10000;
peruse = 95;
if myStepperBoard.isDeviceReady()

    myStepperBoard.setMotorAcceleration(0,9,13);           % Need to be before config
    myStepperBoard.setMotorConfig(0, 0, 1, 0, 0);

    topFreq = 180;
    myStepperBoard.setMotorTopFrequency(0, topFreq);
    
%     moveToEndPoint(myStepperBoard, 'r', peruse, dt);
    
    % coarse measurement
    [coarsesteps, coarsetimes] = measureSliderLength(myStepperBoard, ...
        10, 4000, 10, peruse);
    alldiffs = diff(coarsetimes);
    ifirst = find(abs(diff(coarsetimes))<max(alldiffs)/10, 1);
    rangecoarse = coarsesteps(ifirst + [-1 1]);
    printstr = '==============================================';
    fprintf('%s\rangecoarse length between %d and %d rotations\n%s\n', ...
        printstr, rangeout(1), rangecoarse(2), printstr)
    fprintf('Refining 1... \n')
    [finesteps, finetimes] = measureSliderLength(myStepperBoard,...
        rangecoarse(1)-50, rangecoarse(2)+50, 10, peruse);
    alldiffs = diff(finetimes);
    ifirst = find(abs(diff(finetimes))<max(alldiffs)/10, 1);
    rangefine = finesteps(ifirst + [-1 1]);
    
    
    fprintf('Refining 2... \n')
    [fineststeps, finesttimes] = measureSliderLength(myStepperBoard,...
        rangefine(1)-20, rangefine(2)+20, 8, peruse);
    
    alltimes = [coarsetimes'; finetimes';finesttimes'];
    allsteps = [coarsesteps'; finesteps';fineststeps'];
    [sortedsteps, isort] = sort(allsteps, 'ascend');
    
    
end
myStepperBoard.close();
%%
% probably Nlength = 1620

Nmid = 810;
myStepperBoard = msb2302steppers("COM3", 115200, 0x58);
Nstepsend      = 10000;
peruse = 100;
if myStepperBoard.isDeviceReady()
    myStepperBoard.setMotorAcceleration(0,9,13);           % Need to be before config
    myStepperBoard.setMotorConfig(0, 0, 1, 0, 0);
    myStepperBoard.setMotorTopFrequency(0, 180);
%     moveToEndPoint(myStepperBoard, 'r', peruse);
    moveToEndPoint(myStepperBoard, 'l', peruse);
    myStepperBoard.startMotorRotation(0, Nmid, peruse);
    waitForMotor(myStepperBoard);
    pause(0.1);
    x = 0;
    for ii = 1:20
        nrand = round(randn(1)*20);
        percurr = (0.2+0.8*rand(1))*peruse;
        myStepperBoard.startMotorRotation(0, nrand, percurr);
        waitForMotor(myStepperBoard);
        x = x + nrand;
    end
    myStepperBoard.startMotorRotation(0, Nmid-x, peruse);
    waitForMotor(myStepperBoard);
    pause(2);
    myStepperBoard.startMotorRotation(0, -Nmid, peruse);
    waitForMotor(myStepperBoard);
end

myStepperBoard.close();
