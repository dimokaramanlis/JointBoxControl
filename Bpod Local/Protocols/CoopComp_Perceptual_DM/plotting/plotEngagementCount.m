function plotEngagementCount(EngagementCountPlot, graphics , counteng)
%PLOTREACTIONTIMES Summary of this function goes here
%   Detailed explanation goes here
%cla(EngagementCountPlot);hold(EngagementCountPlot, 'on');
fields = fieldnames(counteng);

for imouse =1:2
    cla(EngagementCountPlot(imouse));
    hold(EngagementCountPlot(imouse), 'on');
    mousecol = graphics.mouseColor(imouse, :);
    lighter = mousecol + 0.4*(1 - mousecol);
    colorsToUse = [lighter;mousecol];
    
    barWidth = 0.35;
    xBase = 1:size(counteng.(fields{1}), 2);
    offsets = [+barWidth/2,-barWidth/2];
    
    for iOutcome = 2:-1:1
        ymax = 1;
        y = counteng.(fields{iOutcome})(imouse, :);
        x = xBase + offsets(iOutcome);

        bar(EngagementCountPlot(imouse), x, y, barWidth, ...
            'FaceColor', colorsToUse(iOutcome,:), ...
            'EdgeColor', 'none');

        %ymax = max([ymax max(counteng(imouse,:))]);
        %ymax = max([ceil(ymax/0.2)*0.2 0.2]);
    end
    ylim(EngagementCountPlot(imouse), [0 ymax]);
    xlim(EngagementCountPlot(imouse), [0 5]); %xlim(size(counteng,2))
    yticks(EngagementCountPlot(imouse), [0 ymax/4 ymax/2 3*ymax/4 ymax]);

end

end

