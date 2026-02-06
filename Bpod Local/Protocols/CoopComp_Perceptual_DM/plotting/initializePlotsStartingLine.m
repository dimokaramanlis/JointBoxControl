function [myPlots, graphics] = initializePlotsStartingLine(subjectName)
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
p.pack('h', {0.5 0.5});                          % two main columns
p(1).pack('v', 5);                               % left column: 5 stacked plots
p(2).pack('v', 4);            % right column: now 4 rows (last one for fake panel)

% Subdivisions for existing right panels
p(2,1).pack('h', 2);
p(2,2).pack('h', 2);
p(2,3).pack('h', 2);
% the new one (2,4) will be single axis (no subdivision)

% Margins and layout tuning
p.de.margin = 1;
p(1).de.margintop = 15;
p(2).marginleft = 18;
p(2,2).margintop = 20;
p(2).de.marginleft = 5;
p(2,3).de.marginleft = 10;
p(2,3).margintop = 20;
p(2,4).margintop = 30;
p.margin = [15 14 2 15];
p.fontsize = 10;

%--------------------------------------------------------------------------
Ntrials = 12;

myPlots.initationTimePlot = p(1,1).select();
ylim([0 12]); xlim([0.5 Ntrials]);
title('Time to initiate')
ylabel('Time (s)'); 
xticks([1 (1:4)*Ntrials/4]); yticks([0 4 8 12])
xticklabels([])

myPlots.decisionTimePlot = p(1,2).select();
ylim([0 2]); xlim([0.5 Ntrials]);
title('Decision Time')
ylabel('Time (s)'); 
xticks([1 (1:4)*Ntrials/4]);  yticks([0 1 2]);
xticklabels([])

myPlots.choiceTimePlot = p(1,3).select();
ylim([0 4]); xlim([0.5 Ntrials]);
title('Time to spout')
ylabel('Time (s)'); 
xticks([1 (1:4)*Ntrials/4]);  yticks([0 2 4 6]);
xticklabels([])

myPlots.percentageCorrectPlot = p(1,4).select();
ylim([0 1]); xlim([0.5 Ntrials]);
title('Task performance')
ylabel('Proportion correct'); 
xticks([1 (1:4)*Ntrials/4]);  yticks([0 0.5 1]);
xticklabels([])

myPlots.taskEngagementPlot = p(1,5).select();
ylim([0 1]); xlim([0.5 Ntrials]);
title('Side bias')
ylabel('Probability blue (+)'); 
xticks([1 (1:4)*Ntrials/4]); yticks([0 0.5 1]);
xlabel('Trial #')

%==========================================================================
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

    myPlots.engagementCount(ii) = p(2,2,ii).select();
    axis square;
    xlim([0 2])
    xlim([0 5])
    ylabel('Proportion trials')
    xticks([0 1 2 3 4])
    xticklabels({' ','FullEng', 'HalfEng', 'Change', 'Disen'})
    %xticklabels({' ','++', '+', '+-', '0'})
    title('Engagement Count')
    %----------------------------------------------------------------------

end

%==========================================================================
myPlots.OrientationDecisionTimePlot = p(2,3,1).select();
axis square; xlim([-1.05 1]); ylim([0 0.2])
ylabel('Time (s)')
yticks([0 0.5 1]); xticks([-1 -0.5 0 0.5 1])
xlabel('Grating contrast')
title('Time to leave platform')

myPlots.OrientationReactionTimePlot = p(2,3,2).select();
axis square; xlim([-1.05 1]); ylim([0.2 2])
yticks([0.2 0.6 1 1.4 1.8]); xticks([-1 -0.5 0 0.5 1])
xlabel('Grating contrast')
title('Time to reach spout')


%==========================================================================
myPlots.CooperationORCompetitionPerformance = p(2,4).select();
ylim([0 1.3]); xlim([0.5 Ntrials]);
title('Winning / Cooperation Performance')
ylabel('Moving Average'); 
xticks([1 (1:4)*Ntrials/4]); yticks([0 0.5 1]);
xticklabels([])
xlabel('Trial #')
%==========================================================================

%==========================================================================
p.fontsize = 10;
p.title({...
    sprintf('%s %s', strrep(subjectName,'_',' '), date),' '})
%==========================================================================
myPlots.panhandle  = p;
myPlots.psychparams = {[], []};
%==========================================================================

end