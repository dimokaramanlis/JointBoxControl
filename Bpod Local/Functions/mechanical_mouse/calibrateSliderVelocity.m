function sliderinfo = calibrateSliderVelocity(sliderinfo, comport, varargin)
%UNTITLED Summary of this function goes here
%   
if nargin<3
    Ncoarse = 10;
else
    Ncoarse = varargin{1};
end

%%
myStepperBoard = msb2302steppers(comport, 115200, 0x58);
topFreq        = sliderinfo.topFrequency;
Ndist   = 20;

velocitiesmap = round(linspace(100/Ncoarse, 100, Ncoarse));
sliderlength  = sliderinfo.endstopdistance;

if myStepperBoard.isDeviceReady()

    myStepperBoard.setMotorAcceleration(0,9,13);           % Need to be before config
    myStepperBoard.setMotorConfig(0, 0, 1, 0, 0);

    myStepperBoard.setMotorTopFrequency(0, topFreq);
    %----------------------------------------------------------------------
    printstr = '==============================================';
    fprintf('%s\ncalibrating slider time...\n%s\n', printstr, printstr)
    %----------------------------------------------------------------------
    % coarse measurement
    coarsesteps = round(logspace(log10(1),log10(sliderlength), Ndist));
    coarsetimes = nan(Ndist, Ncoarse);
    for ivel = 1:Ncoarse
        coarsetimes(:, ivel) = measureSliderLength(myStepperBoard, ...
            coarsesteps, velocitiesmap(ivel));
    end

    X     = coarsesteps'./velocitiesmap;
    gvals = glmfit(X(:), coarsetimes(:),"normal");

    sliderinfo.timepredictparams = gvals;
    sliderinfo.velocitiesmap     = velocitiesmap;
    sliderinfo.velocitysteps     = coarsesteps;
    sliderinfo.velocitytimes     = coarsetimes;
    fprintf('Done!\n')
    %----------------------------------------------------------------------
end
myStepperBoard.close();
%%
end

