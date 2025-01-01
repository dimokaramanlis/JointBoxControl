function [XX, conabs] = designMatrixSingleMouse(allcontrast, allchoice, chtozero)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%--------------------------------------------------------------------------
% contrast handling
conabs = unique(abs(allcontrast));
XX     = allcontrast./conabs(conabs>0)';
XX(abs(XX)~=1) = 0;
%--------------------------------------------------------------------------
% adding past choice
XX(2:end, end+1) = allchoice(1:end-1).*~chtozero(2:end);
%--------------------------------------------------------------------------

end