function plotCompCoop(percentageCorrectPlot, graphics, ...
    rewardavg, winavg, winmax, wintot, cooptot, coopmax, mousewin, similar_response, bothtot, bothmax,rewtot,rewmax)
 

Ntrials  = size(winavg, 1);
currxlim = xlim(percentageCorrectPlot);

cla(percentageCorrectPlot);hold(percentageCorrectPlot, 'on');

% Plot design: limits and ticks
if currxlim(2) < Ntrials
    newmax = ceil(Ntrials/12)*12;
    xlim(percentageCorrectPlot, [0.5 newmax]);
    xticks(percentageCorrectPlot,[1 newmax/4 newmax/2 3*newmax/4 newmax])
end

%Y line at 0.5
line(percentageCorrectPlot,1:Ntrials, 0.5 * ones(1,Ntrials), 'LineStyle', '--', 'Color', 'k',...
    'LineWidth', 0.5); hold on;

%Cooperation
line(percentageCorrectPlot, 1:Ntrials, rewardavg, ...
        'Marker', '.', 'MarkerSize', 5, 'Color', [0.5 0.5 0.5 0.4], 'LineWidth', 1); hold on;
    
%Winning avg per mouse
for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);
    line(percentageCorrectPlot, 1:Ntrials, winavg(:, imouse), ...
        'Marker', '.', 'MarkerSize', 5, 'Color', [mousecol 0.5], 'LineWidth', 1); hold on;
end

% Plot winner of each round on the top
M1wins = find(mousewin==1);
y_position = ones(length(M1wins),1).*1.1;

M2wins = find(mousewin==2);
y_position2 = ones(length(M2wins),1).*1.2;

plot(percentageCorrectPlot,M1wins,y_position,'o', 'MarkerFaceColor', graphics.mouseColor(1, :), ...
    'MarkerEdgeColor', 'none', 'MarkerSize', 6); hold on;
plot(percentageCorrectPlot,M2wins, y_position2, 'o', 'MarkerFaceColor', graphics.mouseColor(2, :), ...
    'MarkerEdgeColor', 'none', 'MarkerSize', 6); hold on;
% 

tstr1    = sprintf('Proport. win m1: %2.2f/%2.2f, m2: %2.2f/%2.2f',...
    winmax(1),wintot(1),  winmax(2), wintot(2));

tstr2    = sprintf('Coop index: %2.2f/%2.2f; Similarity index: %2.2f.',...
    coopmax(1),cooptot(1), similar_response);

tstr3    = sprintf('Both rewarded: %2.2f/%2.2f. Prop. reward (avg) m1:%2.2f, m2:%2.2f.',...
    bothmax(1), bothtot(1),rewtot(1),rewmax(1));

%Add both correct but not synchronized after I got the correct coop
%Add % of wins

title(percentageCorrectPlot, {tstr1 tstr2 tstr3})


%sprintf('Cooperation, max/avg m1: %2.2f/%2.2f, m2: %2.2f/%2.2f, M1 %i, M2 %i',...coopmax(1),cooptot(1),  coopmax(2), cooptot(2), numel(find(mousewin==1)), numel(find(mousewin==2)));


end

