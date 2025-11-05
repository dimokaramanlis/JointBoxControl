function plotTaskEngagement(taskEngagementPlot, graphics, choiceavg, choicetot, disengavg, rewass, isopto)


Ntrials = size(choiceavg, 1);


cla(taskEngagementPlot);

currxlim = xlim(taskEngagementPlot);

if currxlim(2) < Ntrials
    newmax = ceil(Ntrials/12)*12;
    xlim(taskEngagementPlot, [0.5 newmax]);
    xticks(taskEngagementPlot,[1 newmax/4 newmax/2 3*newmax/4 newmax])
    xticklabels(taskEngagementPlot,[1 newmax/4 newmax/2 3*newmax/4 newmax])
end

tstr1 = sprintf('Task engagement, bias1+: %2.2f, bias2+: %2.2f', choicetot(1), choicetot(2));
tstr2 = sprintf('rew1 blue/red: %d/%d, rew2 blue/red: %d/%d',...
    round(rewass(1)), round(rewass(2)), round(rewass(3)), round(rewass(4)));

title(taskEngagementPlot, {tstr1 tstr2})


line(taskEngagementPlot,1:Ntrials, 0.5 * ones(1,Ntrials),...
    'LineStyle', '--', 'Color', 'k', 'LineWidth', 0.5)

xopto = find(any(isopto, 2));
if numel(xopto) > 0
    xplot = (xopto*[1 1 nan])';
    yplot = repmat([0;1;nan], [1, numel(xopto)]);
    line(taskEngagementPlot, xplot(:), yplot(:), 'Color', graphics.optoColor)
end

for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);
    line(taskEngagementPlot, 1:Ntrials, choiceavg(:, imouse), ...
        'Marker', '.', 'Color', [mousecol 0.5], 'LineWidth', 1,'MarkerSize',3);
    redcol = 0.4*[1 0 0] + 0.6 *mousecol;
    line(taskEngagementPlot, 1:Ntrials, disengavg(:, imouse), ...
        'Marker', '.', 'Color', [redcol 0.5], 'LineWidth', 1,'MarkerSize',3);
end

text(taskEngagementPlot, 1, 0.1, 'Disengagement', 'Color', 'r', 'Fontsize',10)

end

