function res = extractSynchTimings(analogsignal, fs, madfac)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    %%
    plotint = 0.002;
    %----------------------------------------------------------------------
    % first let's adjust our signal
    worksignal = analogsignal - quantile(analogsignal,0.05);
    

    %worksignal = analogsignal - median(analogsignal(1:round(0.1*fs)));
    worksignal = worksignal .* (worksignal>0);
    dsignal    = diff(worksignal);

    Thres = madfac * mad(dsignal, 0);
    
    candons = find(dsignal >  Thres);
    iremon  = false(size(candons));
   
    for ii = 2:numel(candons)
        if candons(ii) - candons(ii-1)<2
            iremon(ii) = true;
        end
    end

    fonsets = candons(~iremon) + 1;
    

    candoffs = find(dsignal <  -Thres);
    iremoff  = false(size(candoffs));
    for ii = 2:numel(candoffs)
        if candoffs(ii) - candoffs(ii-1)<2
            iremoff(ii) = true;
        end
    end
    foffsets = candoffs(~iremoff) + 1;
    
    % remove first offset if smaller than onset
    if foffsets(1) < fonsets(1)
        foffsets(1) = [];
    end

    %match onsets and offsets
    if numel(foffsets)<numel(fonsets)
        fonsets = fonsets(1:end-1);
    end


    assert(numel(foffsets) == numel(fonsets), 'Onset/offset number mismatch')

    res.fonsets  = fonsets;
    res.foffsets = foffsets;
    res.ftimes   = fonsets/fs;
    %----------------------------------------------------------------------
end