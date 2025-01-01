function localsettings = setupLocalSettings()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%==========================================================================
dpfilesettings = fullfile('C:\BoxSettings', 'local_settings.mat');


localsettings = struct();
localsettings.useAIM        = true;
localsettings.useFrame2TTL  = false;
localsettings.pulseWindow   = false;

prompt = {'Analog Input Module record (0: none, 1 2: 1 and 2, 1: just one',...
    'Use Frame2TTL (0 for no and 1 for yes)',...
    'Use Pulse window (set 1 if using Frame 2TTL, 0 for no and 1 for yes)'};
dlgtitle = 'Setting up local settings';
dims     = [1 35];
definput = {'1','0','0'};
answer   = inputdlg(prompt,dlgtitle,dims,definput);
%==========================================================================
if ~isempty(answer{1})
    localsettings.useAIM       = str2num(answer{1});
end
if ~isempty(answer{2})
    localsettings.useFrame2TTL = str2num(answer{2});
end
if ~isempty(answer{3})
    localsettings.pulseWindow = str2num(answer{3});
end
save(dpfilesettings,'-struct', 'localsettings');
%==========================================================================
end

