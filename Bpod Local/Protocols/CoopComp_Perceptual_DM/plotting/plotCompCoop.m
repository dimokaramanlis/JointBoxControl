function plotCompCoop(percentageCorrectPlot, graphics, ...
    perfavg, perfmax, perftot, cooptot, coopmax, mousewin, similar_response)
 

Ntrials  = size(perfavg, 1);
currxlim = xlim(percentageCorrectPlot);

cla(percentageCorrectPlot);hold(percentageCorrectPlot, 'on');

if currxlim(2) < Ntrials
    newmax = ceil(Ntrials/12)*12;
    xlim(percentageCorrectPlot, [0.5 newmax]);
    xticks(percentageCorrectPlot,[1 newmax/4 newmax/2 3*newmax/4 newmax])
end

line(percentageCorrectPlot,1:Ntrials, 0.5 * ones(1,Ntrials), 'LineStyle', '--', 'Color', 'k',...
    'LineWidth', 0.5); hold on;
%plot(percentageCorrectPlot,1:Ntrials, 0.5 * ones(1,Ntrials), 'LineStyle', '--', 'Color', 'k',...
 %   'LineWidth', 0.5);
%plot(percentageCorrectPlot,1:Ntrials, 0.5 * ones(1,Ntrials), '--', 'Color', 'k', 'LineWidth', 1); hold on;

for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);
    %plot(percentageCorrectPlot, 1:Ntrials, perfavg(:, imouse), ...
     %   '-o', 'Color', [mousecol 0.5], 'LineWidth', 1); 
    %plot(percentageCorrectPlot,1:Ntrials, perfavg(:, imouse), '-o', 'Color', [mousecol 0.5], 'LineWidth', 1); hold on;


    line(percentageCorrectPlot, 1:Ntrials, perfavg(:, imouse), ...
        'Marker', '.', 'MarkerSize', 5, 'Color', [mousecol 0.5], 'LineWidth', 1); hold on;
    
end


% Plot winner of round
% % 
M1wins = find(mousewin==1);
y_position = ones(length(M1wins),1).*1.1;

M2wins = find(mousewin==2);
y_position2 = ones(length(M2wins),1).*1.2;
% figure(55); hold on;  % keep existing lines

plot(percentageCorrectPlot,M1wins,y_position,'o', 'MarkerFaceColor', graphics.mouseColor(1, :), ...
    'MarkerEdgeColor', 'none', 'MarkerSize', 6); hold on;
plot(percentageCorrectPlot,M2wins, y_position2, 'o', 'MarkerFaceColor', graphics.mouseColor(2, :), ...
    'MarkerEdgeColor', 'none', 'MarkerSize', 6); hold on;
% 

tstr1    = sprintf('Winning, max/avg m1: %2.2f/%2.2f, m2: %2.2f/%2.2f',...
    perfmax(1),perftot(1),  perfmax(2), perftot(2));

tstr2    = sprintf('Cooperation, max/avg m1: %2.2f/%2.2f, m2: %2.2f/%2.2f. Similarity: %2.2f.',...
    coopmax(1),cooptot(1),  coopmax(2), cooptot(2),similar_response);
title(percentageCorrectPlot, {tstr1 tstr2})


%sprintf('Cooperation, max/avg m1: %2.2f/%2.2f, m2: %2.2f/%2.2f, M1 %i, M2 %i',...coopmax(1),cooptot(1),  coopmax(2), cooptot(2), numel(find(mousewin==1)), numel(find(mousewin==2)));



end

