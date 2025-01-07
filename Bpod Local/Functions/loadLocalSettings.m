function localsettings = loadLocalSettings()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


localsettings = struct();
localsettings.useAIM         = true;
localsettings.useFrame2TTL   = false;
localsettings.pulseWindow    = false;
localsettings.useMouseSlider = false;
%==========================================================================
dpfilesettings = fullfile('C:\BoxSettings', 'local_settings.mat');
if exist(dpfilesettings,'file')
    localsettings = load(dpfilesettings);
end
%==========================================================================
% dpfilesettings = fullfile('C:\BoxSettings', 'local_settings.csv');
% if exist(dpfilesettings,'file')
% 
%     ctoread = readcell(dpfilesettings);
%     cfields = ctoread(1:2:end);
%     cvals   = ctoread(2:2:end);
%     for ii = 1:numel(cfields)
%         localsettings.(cfields{ii}) = strcmp(cvals{ii},'TRUE'); 
%     end
% end
%==========================================================================
if localsettings.pulseWindow
    winsize = 50;
else
    winsize = 1;
end
    
localsettings.pulseWinWidth = winsize;

end

