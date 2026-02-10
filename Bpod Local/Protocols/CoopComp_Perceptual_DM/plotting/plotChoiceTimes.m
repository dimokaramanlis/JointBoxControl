function plotChoiceTimes(choiceTimePlot, graphics, choicetimes,lims_y)

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
validtrials = choicetimes(:);
if isempty(validtrials(~isnan(validtrials)))
    ymax = lims_y;
else
    ymax = max([quantilese(validtrials(~isnan(validtrials)), 0.95) lims_y]);
end
%ymax = max([quantilese(choicetimes(:), 0.95) 1e-3]);
ymax = ceil(ymax*2)/2;
ylim(choiceTimePlot, [0 ymax])
%ylim(choiceTimePlot, [0 ymax])
yticks(choiceTimePlot, [0 lims_y/2 lims_y])

%-------------------------------------------------------------------------
% draw stim
for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);
    line(choiceTimePlot, 1:Ntrials, choicetimes(:, imouse), ...
        'Marker', '.', 'MarkerSize',5,'Color', [mousecol 0.5], 'LineWidth', 1);
end
%-------------------------------------------------------------------------
end