function plotChoiceTimes(choiceTimePlot, graphics, choicetimes)

Ntrials = size(choicetimes, 1);
%-------------------------------------------------------------------------
% update limits
cla(choiceTimePlot);
currxlim = xlim(choiceTimePlot);
if currxlim(2) < Ntrials
    newmax = ceil(Ntrials/12)*12;
    xlim(choiceTimePlot, [0.5 newmax]);
    xticks(choiceTimePlot,[1 newmax/4 newmax/2 3*newmax/4 newmax])
end

ymax = max([quantile(choicetimes(:), 0.95) 1e-3]);
ymax = ceil(ymax);
ylim(choiceTimePlot, [0 ymax])
yticks(choiceTimePlot, [0 ymax/2 ymax])

%-------------------------------------------------------------------------
% draw stim
for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);
    line(choiceTimePlot, 1:Ntrials, choicetimes(:, imouse), ...
        'Marker', '.', 'MarkerSize',5,'Color', [mousecol 0.5], 'LineWidth', 1);
end
%-------------------------------------------------------------------------
end