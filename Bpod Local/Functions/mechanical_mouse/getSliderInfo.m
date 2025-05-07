function sliderinfo = getSliderInfo(folderlook, comport)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%==========================================================================
dpfilesettings = fullfile(folderlook, 'slider_calibration.mat');
if exist(dpfilesettings,'file')
    % load existing
    sliderinfo = load(dpfilesettings);
else
    % calibrate and save
    sliderinfo = calibrateEndStopDistance(comport, 20);
    sliderinfo = calibrateSliderVelocity(sliderinfo, comport, 5);
    sliderinfo.calibrationdate = datetime('now');
    save(dpfilesettings, '-struct', "sliderinfo")
end
%==========================================================================
fprintf('Slider calbibration found from %s, proceeding... \n', ...
     datestr(sliderinfo.calibrationdate))
%==========================================================================
end