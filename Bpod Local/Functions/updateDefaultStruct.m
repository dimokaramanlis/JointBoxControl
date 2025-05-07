    function S = updateDefaultStruct(S, Snew)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

newfields = fieldnames(Snew.GUI);

for ifield = 1:numel(newfields)
    if isfield(S.GUI, newfields{ifield})
        S.GUI.(newfields{ifield}) = Snew.GUI.(newfields{ifield});
        if isfield(S.GUIMeta, newfields{ifield})
            if strcmp(S.GUIMeta.(newfields{ifield}).Style, 'popupmenu')
                Nmax = numel(S.GUIMeta.(newfields{ifield}).String);
                S.GUI.(newfields{ifield}) = min(S.GUI.(newfields{ifield}), Nmax);
            end
        end
    end
end

end