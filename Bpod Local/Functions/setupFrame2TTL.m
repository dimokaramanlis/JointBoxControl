function F = setupFrame2TTL()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
F = Frame2TTL('COM3');
F.LightThreshold = 100;
F.DarkThreshold = 200;
end

