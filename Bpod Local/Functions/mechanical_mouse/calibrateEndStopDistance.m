function sliderinfo = calibrateEndStopDistance(comport, varargin)
%UNTITLED Summary of this function goes here
%   
if nargin<2
    Ncoarse = 10;
else
    Ncoarse = varargin{1};
end

%%
myStepperBoard = msb2302steppers(comport, 115200, 0x58);
maxStepsToMap  = 4000;
minStepsToMap  = 10;
peruse = 95;
if myStepperBoard.isDeviceReady()

    myStepperBoard.setMotorAcceleration(0,9,13);           % Need to be before config
    myStepperBoard.setMotorConfig(0, 0, 1, 0, 0);

    topFreq = 180;
    myStepperBoard.setMotorTopFrequency(0, topFreq);
    
%     moveToEndPoint(myStepperBoard, 'r', peruse, dt);
    %----------------------------------------------------------------------
    % coarse measurement
    [coarsesteps, coarsetimes] = measureSliderLength(myStepperBoard, ...
        minStepsToMap, maxStepsToMap, Ncoarse, peruse);
    alldiffs = diff(coarsetimes);
    ifirst = find(abs(diff(coarsetimes))<max(alldiffs)/10, 1);
    rangecoarse = coarsesteps(ifirst + [-1 1]);
    printstr = '==============================================';
    fprintf('%s\nrangecoarse length between %d and %d rotations\n%s\n', ...
        printstr, rangecoarse(1), rangecoarse(2), printstr)
    %----------------------------------------------------------------------
    % fine measurement
    Nfine = round(Ncoarse * 1.5);
    fprintf('Refining with %d fine measurements...', Nfine)
    [finesteps, finetimes] = measureSliderLength(myStepperBoard,...
        rangecoarse(1)-200, rangecoarse(2)+100, round(Ncoarse * 1.5), peruse);
    fprintf('Refinement done!\n')
    %----------------------------------------------------------------------
    alltimes = [coarsetimes'; finetimes'];
    allsteps = [coarsesteps'; finesteps'];
    [sortedsteps, isort] = sort(allsteps, 'ascend');
    
    % Define start point for the fit
    x = sortedsteps;
    y = alltimes(isort);

    % perform the fit, thanks Gemini!
    [~, x0, ~, ~, ~] = fitBrokenStick(x, y);
    endstopdistance = round(x0);
    %----------------------------------------------------------------------
    fprintf('%s\nTotal distance is %d rotations\n%s\n', ...
        printstr, endstopdistance, printstr)
    %----------------------------------------------------------------------
    sliderinfo.endstopdistance = endstopdistance;
    sliderinfo.timecalibrate   = y;
    sliderinfo.rotcalibrate    = x;
    %----------------------------------------------------------------------
end
myStepperBoard.close();
%%
end

