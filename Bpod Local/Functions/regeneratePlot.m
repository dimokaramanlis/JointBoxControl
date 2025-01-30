function regeneratePlot(varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%--------------------------------------------------------------------------
if nargin<1
    [fname, dp]  = uigetfile('*.mat', 'Select session .mat file: ');
else
    dp = varargin{1};
    [dp, fname] = fileparts(dp);
end
%--------------------------------------------------------------------------
fload = load(fullfile(dp, fname));
[myPlots, graphics] =  initializePlots('regenfile');
myPlots = updatePlots(fload.SessionData, 'regenfile', myPlots, graphics);
[~, cftitle, ~] = fileparts(fname);

print(myPlots.PerformanceFigure, fullfile(dp, [cftitle '.jpeg']),'-djpeg','-r600');

%--------------------------------------------------------------------------
end

