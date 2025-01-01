function plotReactionTimes(OrientationReactionTimePlot, graphics, convec, reactcell)
%PLOTREACTIONTIMES Summary of this function goes here
%   Detailed explanation goes here

% Reaction Times Curve


cla(OrientationReactionTimePlot); 
hold(OrientationReactionTimePlot, 'on');
ymax = 0;
for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);

    if isempty(reactcell{imouse}), continue, end
    meanreact = cellfun(@nanmean, reactcell{imouse});
    semreact  = cellfun(@nansemSuite, reactcell{imouse});

    errorbar(OrientationReactionTimePlot,...
        convec{imouse}, meanreact, semreact,...
        'Marker', 'o', 'MarkerSize',6,...
        'markerfacecolor', mousecol, 'markeredgecolor','k', 'Color', mousecol,...
        'LineWidth',1, 'CapSize', 3, 'LineStyle', 'none');
    ymax = max([ymax max(meanreact+semreact)]);
end

ymax = max([ceil(ymax/0.2)*0.2 0.2]);
ylim(OrientationReactionTimePlot, [0 ymax]);
yticks(OrientationReactionTimePlot, [0 ymax/4 ymax/2 3*ymax/4 ymax]);

% think of updating ylim

end