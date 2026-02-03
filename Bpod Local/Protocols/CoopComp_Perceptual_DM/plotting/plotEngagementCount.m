function plotEngagementCount(EngagementCountPlot, graphics, countEng)
%PLOTREACTIONTIMES Summary of this function goes here
%   Detailed explanation goes here

cla(EngagementCountPlot); 
hold(EngagementCountPlot, 'on');

% ymax = 0;
for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);
    
    bar(countEng(imouse,:), 'Color', mousecol);
%     ymax = max([ymax max(meanreact+semreact)]);
end

%ymax = lims_y;% max([ceil(ymax/0.2)*0.2 0.2]);
%ylim(OrientationReactionTimePlot, [0 ymax]);
%yticks(OrientationReactionTimePlot, [0 ymax/4 ymax/2 3*ymax/4 ymax]);


end