function myPlots = updatePlots(Data, subjectName, myPlots, runsimple)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%--------------------------------------------------------------------------
% here one can do calculations relevant for each plot and pass them as
% arguments
beta    = 0.8; %0.9
Ntrials = max(Data.TrialNumber);
%=========================================================================
% get running averages for performance, choice and disengagement
runavg = getRunningAverages(Data, beta);

%=========================================================================
% do the fits
res = getRudimentaryAnalyses(Data, runavg.isopto, runsimple);
myPlots.psychparams = res.psychparams;
%=========================================================================
% plot initiation time
initiationtimes =  Data.InitiationTime;
if isfield( Data, 'isSpontaneous')
    isspontaneous = Data.isSpontaneous;
else
    isspontaneous = false([size(initiationtimes,1),1]);
end
plotInitiationTimes(myPlots.initationTimePlot, myPlots.graphics, initiationtimes, isspontaneous)
%--------------------------------------------------------------------------
% plot time to leave platform
decidetimes = Data.DecisionTimes;
decidetimes(isnan( Data.MouseChoice)) = NaN;
plotChoiceTimes(myPlots.decisionTimePlot, myPlots.graphics, decidetimes);
%--------------------------------------------------------------------------
% plot time to spout
choicetimes =  Data.ReactionTimes;
choicetimes(isnan( Data.MouseChoice)) = NaN;
plotChoiceTimes(myPlots.choiceTimePlot, myPlots.graphics, choicetimes);
%--------------------------------------------------------------------------
% plot task performance
trialoutcomes =  Data.TrialOutcome;
trialoutcomes(trialoutcomes<0) = NaN;
perftot    = mean(trialoutcomes, 1, 'omitnan');
rewtot     = sum((Data.RewardAmount.*(trialoutcomes>0)), 1, 'omitnan');
Nmax       = min(100, Ntrials);
perfmax    = max(movmean(trialoutcomes, Nmax, 1, ...
    'omitnan', 'Endpoints', 'discard'), [], 1);

plotPercentageCorrect(myPlots.percentageCorrectPlot, myPlots.graphics, ...
    runavg.perfavg, perfmax, perftot, rewtot, runavg.isopto)
%--------------------------------------------------------------------------
% plot task engagement
choicetot = sum( Data.MouseChoice>0, 1);
choicetot = choicetot./sum(abs( Data.MouseChoice)>0, 1);

rplus  = sum( Data.RewardAmount.*( Data.MouseChoice>0).*(trialoutcomes>0), 1, 'omitnan');
rminus = sum( Data.RewardAmount.*( Data.MouseChoice<0).*(trialoutcomes>0), 1, 'omitnan');
plotTaskEngagement(myPlots.taskEngagementPlot, myPlots.graphics,...
    runavg.choiceavg, choicetot, runavg.disengavg, [rplus;rminus], runavg.isopto);
%--------------------------------------------------------------------------
% plot fits
for imouse = 1:2
    % plots
    mousecol   = [myPlots.graphics.mouseColor(imouse, :); myPlots.graphics.optoColor];
    mousecells = res.respcells(:, imouse);
    mousecon   = res.respcons(:, imouse);
    if all(cellfun(@isempty, mousecells)), continue, end

    plotPsychometric(myPlots.PsychometricPlot(imouse), mousecol, ...
        mousecon, mousecells, res.psychparams(:, imouse), runsimple)

    plotPsychometricWeights(myPlots.WeightPlot(imouse), res.psychparams(:, imouse), res.mdlaccuracy(:, imouse))
end
%--------------------------------------------------------------------------
plotReactionTimes(myPlots.OrientationReactionTimePlot, myPlots.graphics, res.respcons, res.respreacts, runsimple)
plotReactionTimes(myPlots.OrientationDecisionTimePlot, myPlots.graphics, res.respcons, res.respdecis, runsimple)
%--------------------------------------------------------------------------
if contains( subjectName, '_')
    iscall = mode(runavg.iscongr);
    switch iscall
        case 1
            extrastr = 'Congruent';
        case 2
            extrastr = 'Random';
        case 3
            extrastr = 'Anticorrelated';
    end
    title(myPlots.panhandle, ...
        {sprintf('%s %s %s', strrep( subjectName,'_',' '), date, extrastr), ' '});
end
%--------------------------------------------------------------------------
end