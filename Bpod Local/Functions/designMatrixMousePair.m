function [XX, conabs] = designMatrixMousePair(allcontrast, ownchoice, otherchoice,chtozero)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

conabs = unique(abs(allcontrast));
XX = allcontrast./conabs(conabs>0)';
XX(abs(XX)~=1) = 0;

Xother =  allcontrast./conabs';
Xother(isnan(Xother)) = 1;
Xother(abs(Xother)~=1) = 0;
Xother         = abs(Xother).*otherchoice;

%--------------------------------------------------------------------------
% adding past choice
XX(2:end, end+1) = ownchoice(1:end-1).*~chtozero(2:end);
%--------------------------------------------------------------------------
%Xother(2:end,end+1) = otherchoice(1:end-1);
XX = [XX Xother];

end