function plotEngagementCount(EngagementCountPlot, graphics , counteng)
%PLOTREACTIONTIMES Summary of this function goes here
%   Detailed explanation goes here
for imouse =1:2
    %cla(EngagementCountPlot); 
    hold(EngagementCountPlot(imouse), 'on');

    ymax = 1;
    mousecol = graphics.mouseColor(imouse, :);
    bar(EngagementCountPlot(imouse), counteng(imouse,:), 'FaceColor', mousecol);
    %xticklabels(EngagementCountPlot(imouse),{' ','FullEng', 'HalfEng', 'Change', 'Disen'})

    %ymax = max([ymax max(counteng(imouse,:))]);
    %ymax = max([ceil(ymax/0.2)*0.2 0.2]);
    ylim(EngagementCountPlot(imouse), [0 ymax]);
    xlim(EngagementCountPlot(imouse), [0 5]); %xlim(size(counteng,2))
    yticks(EngagementCountPlot(imouse), [0 ymax/4 ymax/2 3*ymax/4 ymax]);

end

end

