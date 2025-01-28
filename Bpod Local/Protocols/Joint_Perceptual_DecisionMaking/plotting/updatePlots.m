function myPlots = updatePlots(BpodSystem, S, myPlots, graphics)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%--------------------------------------------------------------------------
% here one can do calculations relevant for each plot and pass them as
% arguments
beta       = 0.8; %0.9
Ntrials = max(BpodSystem.Data.TrialNumber);
%--------------------------------------------------------------------------
% get running averages for performance, choice and disengagement
%%
moldperf   =  [1 1] * 0.5;
moldchoice =  [1 1] * 0.5;
molddiseng =  0;

perfavg    = NaN(Ntrials, 2);
choiceavg  = NaN(Ntrials, 2);
disengavg  = NaN(Ntrials, 2);
iscongr    = zeros(Ntrials, 1);
for ii = 1:Ntrials
    iscongr(ii) = BpodSystem.Data.TrialSettings(ii).GUI.Dependent;
    mcurr       = BpodSystem.Data.TrialOutcome(ii, :);
    chcurr      = BpodSystem.Data.MouseChoice(ii, :);

    dcurr = all(isnan(chcurr));
    molddiseng    = beta * molddiseng + (1 - beta) * dcurr;
    disengavg(ii, :) = molddiseng;
    
    % abort invalid trials
    if any(mcurr<0), continue,  end
    % regress to 0.5 when task setting changes...
    if ~isequal(isnan(mcurr), isnan(moldperf))
        moldperf = ~isnan(mcurr) * 0.5;
    end
    moldperf    = beta * moldperf + (1 - beta) * mcurr;
    perfavg(ii, :) = moldperf;

    
    % abort invalid trials
    if all(isnan(chcurr)), continue,  end
    chcurr = (chcurr+1)/2;
    % regress to 0.5 when task setting changes...
    if ~isequal(isnan(chcurr), isnan(moldchoice))
        moldchoice = ~isnan(chcurr) * 0.5;
    end
    moldchoice    = beta * moldchoice + (1 - beta) * chcurr;
    choiceavg(ii, :) = moldchoice;

    
end
%%
%--------------------------------------------------------------------------
% do the fits
respcells   = cell(1,2);
respcons    = cell(1,2);
respreacts  = cell(1,2);
respdecis   = cell(1,2);

psychparams = cell(1,2);
mdlaccuracy = NaN(1, 2);
dtime = 0.02;
for imouse = 1:2
    mousechoice   = BpodSystem.Data.MouseChoice(:,imouse);
    mousereact    = BpodSystem.Data.ReactionTimes(:,imouse);
    mousedecide   = decideFromSpout(mousereact, mousechoice); %BpodSystem.Data.DecisionTimes(:,imouse);
    mousecontrast = BpodSystem.Data.Contrast(:, imouse);
        
    
    iuse = ~isnan(mousechoice);
    if all(isnan(mousechoice)), continue, end
    [respcons{imouse}, ~, ic] = unique(mousecontrast(iuse));
    respcells{imouse}  = accumarray(ic, mousechoice(iuse)==1, [], @(x) {x});
    respreacts{imouse} = accumarray(ic, mousereact(iuse), [], @(x) {x});
    respdecis{imouse}  = accumarray(ic, mousedecide(iuse), [], @(x) {x});
    %BpodSystem.Data.ReactionTimes
     
    iother      = 2-mod(1,imouse);
    if nnz(iuse) > 8 % at least some observations for fitting
        if nnz(~isnan(sum(BpodSystem.Data.MouseChoice(iuse,:),2))) > 16
            % fit social model
            xx1 = mousecontrast(iuse);
            otherchoice  = BpodSystem.Data.MouseChoice(:, iother);
            otherreact   = BpodSystem.Data.ReactionTimes(:,iother);
            otherreactuse = decideFromSpout(otherreact(iuse), otherchoice(iuse));
            mousereactuse = mousedecide(iuse);

%             otherreactuse = otherreact(iuse) - quantile(otherreact(iuse),0.02);
%             mousereactuse = mousereact(iuse) - quantile(mousereact(iuse),0.02);

            xx2 = otherchoice(iuse);
            xx2(mousereactuse < (otherreactuse + dtime)) = 0;
            
            xx3 = (1-abs(xx1)).*xx2;

            xx = [xx1 xx2 xx3];
            xx(isnan(xx)) = 0;
        else
            % fit contrast model
            xx = mousecontrast(iuse);
        end
        %temporary fix 
%         psychparams{imouse} = []; 

%         [bfit, binfo] = lassoglm(xx, mousechoice(iuse)==1, 'binomial', 'Alpha', 1e-5,'NumLambda', 20);
%         psychparams{imouse} = [0;0;bfit(:,1);binfo.Intercept(1)];
%         
        bfit = glmfit(xx, mousechoice(iuse)==1, 'binomial');
        psychparams{imouse} =bfit;

%         psychparams{imouse} = fitPsychologisticML(xx, mousechoice(iuse)==1, myPlots.psychparams{imouse});
        if ~isempty(psychparams{imouse})
            modelpred   = glmval(psychparams{imouse}, xx, 'logit') > 0.5;
            mdlaccuracy(imouse) = mean(modelpred == (mousechoice(iuse)==1));
        end
    end       
end
myPlots.psychparams = psychparams;
%--------------------------------------------------------------------------
% do plotting
initiationtimes = BpodSystem.Data.InitiationTime;
if isfield(BpodSystem.Data, 'isSpontaneous')
    isspontaneous   = BpodSystem.Data.isSpontaneous;
else
    isspontaneous = false([size(initiationtimes,1),1]);
end
plotInitiationTimes(myPlots.initationTimePlot, graphics, initiationtimes, isspontaneous)
%--------------------------------------------------------------------------
decidetimes = BpodSystem.Data.DecisionTimes;
decidetimes(isnan(BpodSystem.Data.MouseChoice)) = NaN;

plotChoiceTimes(myPlots.decisionTimePlot, graphics, decidetimes);
%--------------------------------------------------------------------------
choicetimes = BpodSystem.Data.ReactionTimes;
choicetimes(isnan(BpodSystem.Data.MouseChoice)) = NaN;
plotChoiceTimes(myPlots.choiceTimePlot, graphics, choicetimes);
%--------------------------------------------------------------------------
trialoutcomes = BpodSystem.Data.TrialOutcome;
trialoutcomes(trialoutcomes<0) = NaN;
perftot    = mean(trialoutcomes, 1, 'omitnan');
rewtot     = sum(BpodSystem.Data.RewardAmount.*trialoutcomes, 1, 'omitnan');
Nmax       = min(100, Ntrials);
perfmax    = max(movmean(trialoutcomes, Nmax, 1, ...
    'omitnan', 'Endpoints', 'discard'), [], 1);

plotPercentageCorrect(myPlots.percentageCorrectPlot,graphics, perfavg, perfmax, rewtot)
%--------------------------------------------------------------------------
choicetot = sum(BpodSystem.Data.MouseChoice>0, 1);
choicetot = choicetot./sum(abs(BpodSystem.Data.MouseChoice)>0, 1);

rplus  = sum(BpodSystem.Data.RewardAmount.*trialoutcomes.*...
    (BpodSystem.Data.MouseChoice>0), 1, 'omitnan');
rminus = sum(BpodSystem.Data.RewardAmount.*trialoutcomes.*...
    (BpodSystem.Data.MouseChoice<0), 1, 'omitnan');
plotTaskEngagement(myPlots.taskEngagementPlot, graphics, choiceavg, choicetot, disengavg, [rplus;rminus]);
%--------------------------------------------------------------------------
% plot fits
for imouse = 1:2
    % plots
    mousecol = graphics.mouseColor(imouse, :);
    
    if isempty(respcells{imouse}), continue, end
    plotPsychometric(myPlots.PsychometricPlot(imouse), mousecol, ...
        respcons{imouse}, respcells{imouse}, psychparams{imouse})
    plotPsychometricWeights(myPlots.WeightPlot(imouse), psychparams{imouse}, mdlaccuracy(imouse))
end
%--------------------------------------------------------------------------
plotReactionTimes(myPlots.OrientationReactionTimePlot, graphics, respcons, respreacts)
plotReactionTimes(myPlots.OrientationDecisionTimePlot, graphics, respcons, respdecis)

%--------------------------------------------------------------------------
if contains(BpodSystem.Status.CurrentSubjectName, '_')
    iscall = mode(iscongr);
    switch iscall
        case 1
            extrastr = 'Congruent';
        case 2
            extrastr = 'Random';
        case 3
            extrastr = 'Anticorrelated';
    end
    title(myPlots.panhandle, {sprintf('%s %s %s', ...
        strrep(BpodSystem.Status.CurrentSubjectName,'_',' '), date, extrastr),...
        ' '});
end
%--------------------------------------------------------------------------
end