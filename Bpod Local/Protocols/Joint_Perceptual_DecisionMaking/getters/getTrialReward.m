function trialreward = getTrialReward(currstim, isdependent)

%GETTRIALREWARD Summary of this function goes here
%   Detailed explanation goes here

trialreward = sign(currstim);

% most common case
if nnz(currstim==0)==0, return; end

if nnz(currstim==0)==1
    irand = 2 * (rand(1) > 0.5) - 1; % draw random
    if numel(currstim) == 1
        trialreward = irand;
    else
        if abs(isdependent) > 0
            trialreward(currstim==0) =  sign(isdependent) * trialreward(currstim~=0);
        else
            trialreward(currstim==0) = irand;
        end
    end
    return;
end

if nnz(currstim==0)==2
    irand = 2 * (rand(1,2) > 0.5) - 1; % draw random
    if isdependent > 0
        trialreward = irand(1) * ones(size(irand));
    elseif isdependent < 0
        trialreward    = irand(1) * ones(size(irand));
        trialreward(2) = -trialreward(1);
    else
        trialreward = irand;
    end
end

end

