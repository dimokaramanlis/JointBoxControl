function ops = getGlobalOptions(localsettings)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%----------------------------------------------------------------------------
% define contrast sets
confull      = 1;
contrain     = [0.5, 1];
coneasy      = [0.12, 0.24, 0.50, 1];
conhard      = [0.06, 0.12, 0.24, 0.50, 1];
conhard0     = [0, 0.06, 0.12, 0.24, 0.50, 1]; 
conhard0w50  = [0, 0.06, 0.12, 0.24]; 
stimsets     = {confull, contrain, coneasy, conhard, conhard0, conhard0w50};
stimsetnames = {'Con100', 'Con100_50', 'Con100_to_12', ...
    'Con100_to_6', 'Con100_to_0', 'Con24,12,6,0'};
%----------------------------------------------------------------------------
% set global options
ops.degPositive  = 45;
ops.degNegative  = -45;
ops.sliderCOM    = sprintf("COM%d", localsettings.sliderCOM);
% ops.degPositive  = 45;
% ops.degNegative  = 135;
ops.pulseWinWidth = localsettings.pulseWinWidth;
ops.useAIM        = localsettings.useAIM;
ops.useSlider     = localsettings.useMouseSlider;
ops.useOpto       = localsettings.useOpto;
ops.degPerPixel   = 92/1280;
ops.screenFs      = 60; % make sure this matches your screen refresh rates!
ops.stimsets      = stimsets;
ops.stimsetnames  = stimsetnames;
ops.probsettings  = {'Pseudorandom','Alternate','RepeatTrials'};
%----------------------------------------------------------------------------
% nosepoke map
ops.valves.m1Red     = 'Valve1';
ops.nosepokes.m1Red  = 'Port1In';
ops.valves.m1Blue    = 'Valve4';
ops.nosepokes.m1Blue = 'Port4In';
ops.valves.m2Red     = 'Valve2';
ops.nosepokes.m2Red  = 'Port2In';
ops.valves.m2Blue    = 'Valve3';
ops.nosepokes.m2Blue = 'Port3In';
%----------------------------------------------------------------------------
end