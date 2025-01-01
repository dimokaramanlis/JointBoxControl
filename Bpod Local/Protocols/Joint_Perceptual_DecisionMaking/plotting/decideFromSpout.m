function mdecide = decideFromSpout(mreact, mchoice)
%DECIDEFROMSPOUT Summary of this function goes here
%   Detailed explanation goes here
mdecide = mreact;
mdecide(isnan(mchoice)) = NaN;

for imouse = 1:size(mdecide, 2)
    iplus    = mchoice(:, imouse) > 0;
    iminus   = mchoice(:, imouse) < 0;
    runplus  = min(mdecide(iplus, imouse),  [], 'all');
    runminus = min(mdecide(iminus, imouse), [], 'all');
    mdecide(iplus, imouse)  = mdecide(iplus, imouse)  - runplus;
    mdecide(iminus, imouse) = mdecide(iminus, imouse) - runminus;
end

end

