function [behpath,filmpath] = generateSavePaths(MouseName, ProtocolName, datetext)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

behpath  = fullfile('C:\Data\', MouseName, 'Behavior', ...
    ProtocolName, datetext, 'Session0');
filmpath = fullfile('C:\Data\', MouseName, 'Filming',  ...
    ProtocolName, datetext, 'Session0');

isnewpath = true;
sessid    = 0;
while isnewpath
    sessid = sessid + 1;
    behpath  = [behpath(1:end-1) num2str(sessid)];
    filmpath = [filmpath(1:end-1) num2str(sessid)];
    if ~exist(behpath,'dir')
        mkdir(behpath);
        mkdir(filmpath);
        isnewpath = false;
    end
end

end