function [randId, pnew] = sampleAndRemove(pold)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

Nstimuli = numel(pold);

% draw random sample based on old probability distro
randsample = rand(1);
randloc    = histcounts(randsample, [0; cumsum(pold)]);
randId     = find(randloc);

% redistribute probabilities
pdist = pold(randId);
pnew  = pold + pdist/(Nstimuli-1);
pnew(randId) = 0;
pnew = pnew.^4;
pnew = pnew/sum(pnew);

% to deal with alternating samples for Ncon = 1
if numel(pold) < 3
    pnew  = pold;
    pnew(randId) = 0;
    pnew = pnew + pdist/(Nstimuli-1);
    pnew = pnew.^1.8/sum(pnew.^1.8);
end



end