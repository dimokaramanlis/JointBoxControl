function trialset = getTrialSet(conset, mousesetting, isdependent)
%GETTRIALSET Summary of this function goes here
%   Detailed explanation goes here

if numel(mousesetting) == 1
    currset  = conset{mousesetting}(:);
    finalset = cat(1, currset, -currset);
    finalset = unique(finalset);
end
%--------------------------------------------------------------------------
if numel(mousesetting) == 2
    finalset1 = cat(1, conset{1}(:), -conset{1}(:));
    finalset1 = unique(finalset1);

    finalset2 = cat(1, conset{2}(:), -conset{2}(:));
    finalset2 = unique(finalset2);

    [cta, ctb] = meshgrid(finalset1, finalset2);
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

