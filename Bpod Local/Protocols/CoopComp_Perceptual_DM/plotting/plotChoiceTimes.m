function plotChoiceTimes(choiceTimePlot, graphics, choicetimes,lims_y,spout)

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
%yticks(choiceTimePlot, [0 lims_y/2 lims_y])

%-------------------------------------------------------------------------
% draw stim
for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);
    line(choiceTimePlot, 1:Ntrials, choicetimes(:, imouse), ...
        'Marker', '.', 'MarkerSize',5,'Color', [mousecol 0.5], 'LineWidth', 1);
end


medianchoicetime = median(choicetimes, 1, 'omitnan');
Nmax               = min(Ntrials, 100);
medchoicetime      = movmedian(choicetimes, Nmax, 1, 'omitnan', 'Endpoints', 'discard');
tstr = sprintf('Median/max median time m1: %2.2f/%2.2f, m2: %2.2f/%2.2f.', ...
    medchoicetime(1),medianchoicetime(1),medchoicetime(2),medianchoicetime(2));

if spout
    title_plot = sprintf('Time to spout');
    title(choiceTimePlot, {title_plot tstr})    
else
    title_plot = sprintf('Decision Time');
    title(choiceTimePlot, {title_plot tstr}) 
end


%-------------------------------------------------------------------------
end