function [outputArg1,outputArg2] = calibrateEndStopDistance(inputArg1,inputArg2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%%
myStepperBoard = msb2302steppers("COM3", 115200, 0x58);
maxStepsToMap  = 4000;
minStepsToMap  = 10;
peruse = 95;
if myStepperBoard.isDeviceReady()

    myStepperBoard.setMotorAcceleration(0,9,13);           % Need to be before config
    myStepperBoard.setMotorConfig(0, 0, 1, 0, 0);

    topFreq = 180;
    myStepperBoard.setMotorTopFrequency(0, topFreq);
    
%     moveToEndPoint(myStepperBoard, 'r', peruse, dt);
    
    % coarse measurement
    [coarsesteps, coarsetimes] = measureSliderLength(myStepperBoard, ...
        minStepsToMap, maxStepsToMap, 10, peruse);
    alldiffs = diff(coarsetimes);
    ifirst = find(abs(diff(coarsetimes))<max(alldiffs)/10, 1);
    rangecoarse = coarsesteps(ifirst + [-1 1]);
    printstr = '==============================================';
    fprintf('%s\rangecoarse length between %d and %d rotations\n%s\n', ...
        printstr, rangecoarse(1), rangecoarse(2), printstr)
    fprintf('Refining 1... \n')
    [finesteps, finetimes] = measureSliderLength(myStepperBoard,...
        rangecoarse(1)-100, rangecoarse(2)+100, 15, peruse);

    alltimes = [coarsetimes'; finetimes'];
    allsteps = [coarsesteps'; finesteps'];
    [sortedsteps, isort] = sort(allsteps, 'ascend');
    
   

    % Define start point for the fit
    x = sortedsteps;
    y = alltimes(isort);
    start_point = [1, median(-x), min(-y)];
    % Define the softplus function
    softplus = @(b, x) log(1 + exp(b(1)*(x - b(2)))) + b(3); 

    % Fit the data
    options = optimoptions('lsqcurvefit','Display','off');
    [b,~,residual,~,~,~,jacobian] = lsqcurvefit(softplus, start_point, -x, -y, [], [], options);
    
    sst = sum((y - mean(y)).^2);
    sse = sum(residual.^2);
    gof.rsquare = 1 - sse/sst;

    % Plot the fit and the data
    xvals = linspace(min(-x), max(-x));
    plot(xvals,softplus(b,xvals),'-', -x, -y,'o');
    xlabel('x');
    ylabel('y');
    title('Data and Fitted Softplus Function');
    legend('Data', 'Fitted Curve');

    
end
myStepperBoard.close();
%%
end

