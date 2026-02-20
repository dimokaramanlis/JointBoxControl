function plotPercentageCorrect(percentageCorrectPlot, graphics, perfavg, perfmax, perftot, rewtot,disengcross,plotDiseng )

Ntrials  = size(perfavg, 1);

cla(percentageCorrectPlot);

currxlim = xlim(percentageCorrectPlot);

if currxlim(2) < Ntrials
    newmax = ceil(Ntrials/12)*12;
    xlim(percentageCorrectPlot, [0.5 newmax]);
    xticks(percentageCorrectPlot,[1 newmax/4 newmax/2 3*newmax/4 newmax])
    
end

line(percentageCorrectPlot,1:Ntrials, 0.5 * ones(1,Ntrials), 'LineStyle', '--', 'Color', 'k', 'LineWidth', 0.5)

for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);
    line(percentageCorrectPlot, 1:Ntrials, perfavg(:, imouse), ...
        'Marker', '.', 'MarkerSize', 6-imouse, 'Color', [mousecol 0.5], 'LineWidth', 3-imouse);
    
    
        if plotDiseng
            redcol = 0.4*[1 0 0] + 0.6 *mousecol;
            line(percentageCorrectPlot, 1:Ntrials, disengcross(:, imouse), ...
            'Marker', '.', 'Color', [redcol 0.5], 'LineWidth', 1,'MarkerSize',3);
        end
    
end

text(percentageCorrectPlot, 1, 0.1, 'Cross Disengagement', 'Color', 'r', 'Fontsize',10)

tstr1    = sprintf('Task performance, max/avg m1: %2.2f/%2.2f, m2: %2.2f/%2.2f',...
    perfmax(1),perftot(1),  perfmax(2), perftot(2));
tstr2    = sprintf('Reward consumed (ul), m1: %d, m2: %d', round(rewtot(1)), round(rewtot(2)));

title(percentageCorrectPlot, {tstr1 tstr2})


end

