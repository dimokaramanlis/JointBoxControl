function plotInitiationTimes(initationTimePlot,graphics, initiationtimes, isspont)


Ntrials = size(initiationtimes, 1);

cla(initationTimePlot);

currxlim = xlim(initationTimePlot);

if currxlim(2) < Ntrials
    newmax = ceil(Ntrials/12)*12;
    xlim(initationTimePlot, [0.5 newmax]);
    xticks(initationTimePlot, [1 newmax/4 newmax/2 3*newmax/4 newmax])
end

ymax = max([quantile(initiationtimes(:), 0.95) 1e-3]);
%ymax = max(initiationtimes, [], 'all');

ymax = ceil(ymax);
ylim(initationTimePlot, [0 ymax])
yticks(initationTimePlot, [0 ymax/2 ymax])

for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);
    line(initationTimePlot,...
        1:Ntrials, initiationtimes(:, imouse), 'Marker', '.', ...
        'MarkerSize',5,'Color',[mousecol 0.5], 'LineWidth', 1);
end
Nmousetrials = nnz(~isspont);
Nwindow      = min(Ntrials, 100);
medinit      = min(movmedian(median(initiationtimes(~isspont,:), 2, 'omitnan'), Nwindow));
medinit      = medinit(~isnan(medinit));
tstr = sprintf('Time to initiate (med = %2.2f), Ntrialsmouse = %d (%2.2f)', ...
    medinit, Nmousetrials, Nmousetrials/Ntrials);
title(initationTimePlot, tstr)

end

