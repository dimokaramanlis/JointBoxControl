function plotEngagementCount(EngagementCountPlot, graphics , counteng)
%PLOTREACTIONTIMES Summary of this function goes here
%   Detailed explanation goes here
fields = fieldnames(counteng);

for imouse =1:2
    mousecol = graphics.mouseColor(imouse, :);
    lighter = mousecol + 0.4*(1 - mousecol);
    colorsToUse = [lighter;mousecol];
    
    barWidth = 0.35;
    xBase = 1:size(counteng.(fields{1}), 2);
    offsets = [-barWidth/2, +barWidth/2];
    
    for iOutcome = 2:-1:1
        %cla(EngagementCountPlot); 
        hold(EngagementCountPlot(imouse), 'on');

        ymax = 1;
        y = counteng.(fields{iOutcome})(imouse, :);
        x = xBase + offsets(iOutcome);

        bar(EngagementCountPlot(imouse), x, y, barWidth, ...
            'FaceColor', colorsToUse(iOutcome,:), ...
            'EdgeColor', 'none');
        
        %bar(EngagementCountPlot(imouse), counteng.(fieldnames1{iOutcome})(imouse,:), 'FaceColor', colorsToUse(iOutcome,:));
        %hold on;
        %xticklabels(EngagementCountPlot(imouse),{' ','FullEng', 'HalfEng', 'Change', 'Disen'})

        %ymax = max([ymax max(counteng(imouse,:))]);
        %ymax = max([ceil(ymax/0.2)*0.2 0.2]);
    end
    ylim(EngagementCountPlot(imouse), [0 ymax]);
    xlim(EngagementCountPlot(imouse), [0 5]); %xlim(size(counteng,2))
    yticks(EngagementCountPlot(imouse), [0 ymax/4 ymax/2 3*ymax/4 ymax]);

end

end

