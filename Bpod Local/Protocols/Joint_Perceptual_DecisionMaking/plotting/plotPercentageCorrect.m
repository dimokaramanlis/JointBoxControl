function plotPercentageCorrect(percentageCorrectPlot, graphics, perfavg, perftot, rewtot)


Ntrials  = size(perfavg, 1);
currxlim = xlim(percentageCorrectPlot);

cla(percentageCorrectPlot);

if currxlim(2) < Ntrials
    newmax = ceil(Ntrials/12)*12;
    xlim(percentageCorrectPlot, [0.5 newmax]);
    xticks(percentageCorrectPlot,[1 newmax/4 newmax/2 3*newmax/4 newmax])
end

line(percentageCorrectPlot,1:Ntrials, 0.5 * ones(1,Ntrials), 'LineStyle', '--', 'Color', 'k',...
    'LineWidth', 0.5)

for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);
    line(percentageCorrectPlot, 1:Ntrials, perfavg(:, imouse), ...
        'Marker', '.', 'MarkerSize', 5, 'Color', [mousecol 0.5], 'LineWidth', 1);
end

tstr1    = sprintf('Task performance,     m1: %2.2f, m2: %2.2f', perftot(1), perftot(2));
tstr2    = sprintf('Reward consumed (ul), m1: %d, m2: %d', round(rewtot(1)), round(rewtot(2)));

title(percentageCorrectPlot, {tstr1 tstr2})


%     myWindow= graphics.myWindow;
%     windowDivisor = graphics.myWindow(1)+graphics.myWindow(2);
%     avgTrialOutcome = movsum((BpodSystem.Data.TrialOutcome==1|BpodSystem.Data.TrialOutcome==2),myWindow);
%     avgTrialOutcomeDivisor = movsum(BpodSystem.Data.TrialOutcome>0,myWindow);
%     avgTrialOutcome = avgTrialOutcome./avgTrialOutcomeDivisor;
%     plot(percentageCorrectPlot,... %ax
%          BpodSystem.Data.TrialNumber,...%x
%          avgTrialOutcome,...
%          'LineWidth',2,'Color',graphics.m1Color);
%     hold(percentageCorrectPlot,'on');
%     avgTrialOutcome = movsum((BpodSystem.Data.TrialOutcome==1|BpodSystem.Data.TrialOutcome==3),myWindow);
%     avgTrialOutcomeDivisor = movsum(BpodSystem.Data.TrialOutcome>0,myWindow);
%     avgTrialOutcome = avgTrialOutcome./avgTrialOutcomeDivisor;
%     plot(percentageCorrectPlot,... %ax
%          BpodSystem.Data.TrialNumber,...%x
%          avgTrialOutcome,...
%          'LineWidth',2,'Color',graphics.m2Color); %y
%     meanM1 = sum(BpodSystem.Data.TrialOutcome==1|BpodSystem.Data.TrialOutcome==2)/sum(BpodSystem.Data.TrialOutcome>0);
%     meanM2 = sum(BpodSystem.Data.TrialOutcome==1|BpodSystem.Data.TrialOutcome==3)/sum(BpodSystem.Data.TrialOutcome>0);
%     if ~isnan(meanM1)
%         yline(percentageCorrectPlot,meanM1,'--','Mean M1','Color',graphics.m1Color);
%     end
%     if ~isnan(meanM2)
%         yline(percentageCorrectPlot,meanM2,'--','Mean M2','Color',graphics.m2Color);
%     end
%     title(percentageCorrectPlot,['Fraction Correct (Window ' num2str(windowDivisor) ' trials)']);
%     xlabel(percentageCorrectPlot,'Trial (n)');
%     ylabel(percentageCorrectPlot,'Fraction (%)');
%     ylim(percentageCorrectPlot,[-0.1,1.1]);
%     xlim(percentageCorrectPlot, [0 max(BpodSystem.Data.TrialNumber)]);
%     hold(percentageCorrectPlot,'off');




end

