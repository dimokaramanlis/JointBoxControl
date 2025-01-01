function S = updateDefaultStruct(S, Snew)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

newfields = fieldnames(Snew.GUI);

for ifield = 1:numel(newfields)
    if isfield(S.GUI, newfields{ifield})
        S.GUI.(newfields{ifield}) = Snew.GUI.(newfields{ifield});
    end
end

end