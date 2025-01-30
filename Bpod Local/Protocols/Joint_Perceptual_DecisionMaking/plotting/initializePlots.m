function [myPlots, graphics] = initializePlots(subjectName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%==========================================================================
% setup parameters for plotting
graphics.myWindow= [6 6];
graphics.mouseColor = [252/255 92/255 3/255; 1/255 124/255 1/255];
graphics.markerSize = 3;
graphics.leftChoiceColor      = [0.5 0.15 0.15];
graphics.leftRewardedColor    = [0.75,0.3,0.1];
graphics.leftUnrewardedColor  = [0.75,0.55,0.55];
graphics.rightChoiceColor     = [0.15 0.15 0.5];
graphics.rightRewardedColor   = [0.1,0.3,0.75];
graphics.rightUnrewardedColor = [0.55,0.55,0.75];
%==========================================================================
set(groot, 'DefaultAxesTickDir', 'out');
set(groot, 'DefaultAxesTickDirMode', 'manual');
set(groot, ...
    'DefaultFigureColor', [1,1,1], ...              % Figure properties
    'DefaultAxesBox' ,'off',...
    'DefaultAxesXColor', 'k', ...
    'DefaultAxesYColor', 'k', ...
    'DefaultAxesFontName', 'Arial', ...
    'DefaultTextColor', [0, 0, 0], ...
    'DefaultTextFontName', 'Arial',...
    'DefaultAxesFontSize', 11,...
    'DefaultAxesTickLength', [0.03 0.03]);
%==========================================================================
% TotalRewardDisplay('init'); % Total Reward display (online display of the total amount of liquid reward earned)
myPlots.PerformanceFigure = figure('Name','Mouse Performance', 'Position',[50 50 900 800],'Color', 'w');
%--------------------------------------------------------------------------
% setup panels

p = panel();
p.pack('h', {0.5 0.5});
p(1).pack('v', 5);
p(2).pack('v',{0.4 0.3 0.3});
p(2,1).pack('h', 2);
p(2,2).pack('h', 2);
p(2,3).pack('h', 2);
p.de.margin = 1;
p(1).de.margintop = 15;
p(2).marginleft = 18;
p(2,2).margintop = 8;
p(2).de.marginleft = 5;
p(2,3).de.marginleft = 10;
p(2,3).margintop = 15;
p.margin = [15 14 2 11];
p.fontsize = 10;

%--------------------------------------------------------------------------
% format axes in panels

Ntrials = 12;

myPlots.initationTimePlot = p(1,1).select();
ylim([0 12]); xlim([0.5 Ntrials]);
title('Time to initiate')
ylabel('Time (s)'); 
xticks([1 (1:4)*Ntrials/4]); yticks([0 4 8 12])
xticklabels([])

myPlots.decisionTimePlot = p(1,2).select();
ylim([0 1]); xlim([0.5 Ntrials]);
title('Time to leave platform')
ylabel('Time (s)'); 
xticks([1 (1:4)*Ntrials/4]);  yticks([0 0.5 1]);
xticklabels([])

myPlots.choiceTimePlot = p(1,3).select();
ylim([0 6]); xlim([0.5 Ntrials]);
title('Time to spout')
ylabel('Time (s)'); 
xticks([1 (1:4)*Ntrials/4]);  yticks([0 2 4 6]);
xticklabels([])

myPlots.percentageCorrectPlot = p(1,4).select();
ylim([0 1]); xlim([0.5 Ntrials]);
title('Task performance')
ylabel('Proportion correct'); 
xticks([1 (1:4)*Ntrials/4]); yticks([0 0.5 1]);
xticklabels([])

myPlots.taskEngagementPlot = p(1,5).select();
ylim([0 1]); xlim([0.5 Ntrials]);
title('Task engagement')
ylabel('Probability blue (+)'); 
xticks([1 (1:4)*Ntrials/4]); yticks([0 0.5 1]);
xlabel('Trial #')

for ii = 1:2
    %----------------------------------------------------------------------
    myPlots.PsychometricPlot(ii) = p(2,1,ii).select();
    axis square; xlim([-1 1]*1.05); ylim([0 1])
    yticks([0 0.5 1]); xticks([-1 -0.5 0 0.5 1])
    yticklabels([]); xlabel('Grating contrast')
    if ii == 1
        ylabel('Proportion blue (+)')
        yticklabels([0 0.5 1])
    end
    title({'Psychometric with 95%% CI ', 'lapse blue = 0, red = 0'})
    %----------------------------------------------------------------------
    myPlots.WeightPlot(ii) = p(2,2,ii).select();
    pbaspect([1.5 1 1]); xlim([0 1]); ylim([-1 1]*1.5)
    yticks([-1 0 1]); xticks([0 0.5 1])
    yticklabels([]); xlabel('Contrast')
    if ii == 1
        ylabel('Weight')
        yticklabels([-1 0 1])
    end
    %----------------------------------------------------------------------

end

%==========================================================================
myPlots.OrientationDecisionTimePlot = p(2,3,1).select();
axis square; xlim([-1 1]*1.02); ylim([0 0.2])
ylabel('Time (s)')
yticks([0 0.5 1]); xticks([-1 -0.5 0 0.5 1])
xlabel('Grating contrast')
title('Time to leave platform')

myPlots.OrientationReactionTimePlot = p(2,3,2).select();
axis square; xlim([-1 1]*1.02); ylim([0.2 1.8])
yticks([0.2 0.6 1 1.4 1.8]); xticks([-1 -0.5 0 0.5 1])
xlabel('Grating contrast')
title('Time to reach spout')
%==========================================================================
p.fontsize = 10;
p.title({...
    sprintf('%s %s', strrep(subjectName,'_',' '), date),' '})
%==========================================================================
myPlots.panhandle  = p;
myPlots.psychparams = {[], []};
%==========================================================================

end