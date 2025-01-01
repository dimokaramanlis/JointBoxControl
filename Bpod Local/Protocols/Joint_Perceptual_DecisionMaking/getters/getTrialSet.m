function trialset = getTrialSet(conset, Nmice, isdependent)
%GETTRIALSET Summary of this function goes here
%   Detailed explanation goes here

conset = conset(:);

finalset = cat(1, conset, -conset);
finalset = unique(finalset);

%--------------------------------------------------------------------------
if Nmice == 2
    
    [cta, ctb] = meshgrid(finalset, finalset);
    finalset   = [cta(:) ctb(:)];
    if isdependent > 0
        irem = prod(finalset, 2) < 0;
        finalset(irem, :) = [];
    end
    if isdependent < 0
        irem = prod(finalset, 2) > 0;
        finalset(irem, :) = [];
    end
end
%--------------------------------------------------------------------------
trialset = sortrows(finalset,'ascend');

end

