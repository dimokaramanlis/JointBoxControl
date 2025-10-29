function myPlots = updatePlots(Data, subjectName, myPlots, graphics, runsimple)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%--------------------------------------------------------------------------
% here one can do calculations relevant for each plot and pass them as
% arguments
beta     = 0.8; %0.9
Ntrials = max(Data.TrialNumber);
%--------------------------------------------------------------------------
% get running averages for performance, choice and disengagement
%%
moldperf   =  [1 1] * 0.5;
moldchoice =  [1 1] * 0.5;
moldrew  =  [1 1] * 0.5; moldrewcoop = moldrew;
molddiseng =  0;

perfavg    = NaN(Ntrials, 2);
choiceavg  = NaN(Ntrials, 2);
disengavg  = NaN(Ntrials, 2);
rewardavg  = NaN(Ntrials, 2);
iscongr    = zeros(Ntrials, 1);
for ii = 1:Ntrials
    iscongr(ii) =  Data.TrialSettings(ii).GUI.Dependent;
    mcurr       =  Data.TrialOutcome(ii, :);
    chcurr      =  Data.MouseChoice(ii, :);
    rewout      =  Data.RewardOutcome(ii, :);

    dcurr         = isnan(chcurr);
    molddiseng    = beta * molddiseng + (1 - beta) * dcurr;
    disengavg(ii, :) = molddiseng;
    
    % abort invalid trials
    if any(mcurr<0), continue,  end
    % regress to 0.5 when task setting changes... ???????????
%     if ~isequal(isnan(mcurr), isnan(moldperf))
%         moldperf = ~isnan(mcurr) * 0.5;
%     end
    for this_mouse = 1:length(moldperf)
        if isnan(moldperf(this_mouse)) && ~isnan(mcurr(this_mouse))           
            last_notnan = find(~isnan(perfavg(:,this_mouse)),1,'last');
            moldperf(this_mouse) = perfavg(last_notnan,this_mouse);
        end
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
    
    
    rewout(isnan(rewout)) = 0;
%     for this_mouse = 1:length(moldrew)
%         if isnan(moldrew(this_mouse)) && ~isnan(rewout(this_mouse))           
%             last_notnan = find(~isnan(rewardavg(:,this_mouse)),1,'last');
%             moldrew(this_mouse) = rewardavg(last_notnan,this_mouse);
%         end
%     end
%     
    moldrew    = beta * moldrew + (1 - beta) * rewout;
    rewardavg(ii, :) = moldrew;
   

%     % Shared reward logic (cooperation task)
%     shared_rew = all(rewout == 1);   % 1 if both rewarded, else 0
%     rewcoop = [shared_rew shared_rew]; % identical for both
%     % Moving average update
%     moldrewcoop = beta * moldrewcoop + (1 - beta) * rewcoop;
%     rewardcoopavg(ii, :) = moldrewcoop;

    
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
    mousechoice   =  Data.MouseChoice(:,imouse);
    mousereact    =  Data.ReactionTimes(:,imouse);
    mousedecide   = decideFromSpout(mousereact, mousechoice); % Data.DecisionTimes(:,imouse);
    mousecontrast =  Data.Contrast(:, imouse);
        
    
    iuse = ~isnan(mousechoice);
    if all(isnan(mousechoice)), continue, end
    [respcons{imouse}, ~, ic] = unique(mousecontrast(iuse));
    respcells{imouse}  = accumarray(ic, mousechoice(iuse)==1, [], @(x) {x});
    respreacts{imouse} = accumarray(ic, mousereact(iuse), [], @(x) {x});
    respdecis{imouse}  = accumarray(ic, mousedecide(iuse), [], @(x) {x});
    % Data.ReactionTimes
     
    iother      = 2-mod(1,imouse);
    if nnz(iuse) > 8 % at least some observations for fitting
        if nnz(~isnan(sum( Data.MouseChoice(iuse,:),2))) > 16
            % fit social model
            xx1 = contrastfun(mousecontrast(iuse));
            otherchoice  =  Data.MouseChoice(:, iother);
            otherchoice(isnan(otherchoice)) = 0;
            otherreact   =  Data.ReactionTimes(:,iother);
            otherreactuse = decideFromSpout(otherreact(iuse), otherchoice(iuse));
            mousereactuse = mousedecide(iuse);

%             otherreactuse = otherreact(iuse) - quantile(otherreact(iuse),0.02);
%             mousereactuse = mousereact(iuse) - quantile(mousereact(iuse),0.02);

            xx2 = otherchoice(iuse);
            xx2(mousereactuse < (otherreactuse + dtime)) = 0;
            
            xx3 = xx2.* socialfun(xx1);

            xx = [xx1 xx2 xx3];
            xx(isnan(xx)) = 0;
        else
            % fit contrast model
            xx = mousecontrast(iuse);
        end

        if ~runsimple
            bfit = glmfit(xx, mousechoice(iuse)==1, 'binomial');
            psychparams{imouse} =bfit;
        end

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
initiationtimes =  Data.InitiationTime;
if isfield( Data, 'isSpontaneous')
    isspontaneous   =  Data.isSpontaneous;
else
    isspontaneous = false([size(initiationtimes,1),1]);
end
plotInitiationTimes(myPlots.initationTimePlot, graphics, initiationtimes, isspontaneous)
%--------------------------------------------------------------------------
decidetimes =  Data.DecisionTimes;
decidetimes(isnan( Data.MouseChoice)) = NaN;

plotChoiceTimes(myPlots.decisionTimePlot, graphics, decidetimes);
%--------------------------------------------------------------------------
choicetimes =  Data.ReactionTimes;
choicetimes(isnan( Data.MouseChoice)) = NaN;
plotChoiceTimes(myPlots.choiceTimePlot, graphics, choicetimes);
%--------------------------------------------------------------------------
trialoutcomes =  Data.TrialOutcome;
trialoutcomes(trialoutcomes<0) = NaN;
perftot    = mean(trialoutcomes, 1, 'omitnan');
rewtot     = sum((Data.RewardAmount.*(trialoutcomes>0)), 1, 'omitnan');
Nmax       = min(100, Ntrials);
perfmax    = max(movmean(trialoutcomes, Nmax, 1, ...
    'omitnan', 'Endpoints', 'discard'), [], 1);

plotPercentageCorrect(myPlots.percentageCorrectPlot,graphics, ...
    perfavg, perfmax, perftot, rewtot)
%--------------------------------------------------------------------------
choicetot = sum( Data.MouseChoice>0, 1);
choicetot = choicetot./sum(abs( Data.MouseChoice)>0, 1);

rplus  = sum( Data.RewardAmount.*( Data.MouseChoice>0).*(trialoutcomes>0), 1, 'omitnan');
rminus = sum( Data.RewardAmount.*( Data.MouseChoice<0).*(trialoutcomes>0), 1, 'omitnan');
plotTaskEngagement(myPlots.taskEngagementPlot, graphics, choiceavg, choicetot, disengavg, [rplus;rminus]);
%--------------------------------------------------------------------------
% plot fits
for imouse = 1:2
    % plots
    mousecol = graphics.mouseColor(imouse, :);
    
    if isempty(respcells{imouse}), continue, end
    plotPsychometric(myPlots.PsychometricPlot(imouse), mousecol, ...
        respcons{imouse}, respcells{imouse}, psychparams{imouse}, runsimple)
    plotPsychometricWeights(myPlots.WeightPlot(imouse), psychparams{imouse}, mdlaccuracy(imouse))
end
%--------------------------------------------------------------------------
plotReactionTimes(myPlots.OrientationReactionTimePlot, graphics, respcons, respreacts ,runsimple)
plotReactionTimes(myPlots.OrientationDecisionTimePlot, graphics, respcons, respdecis, runsimple)


%--------------------------------------------------------------------------
rewardoutcomes =  Data.RewardOutcome;

rewtot    = mean(rewardoutcomes, 1, 'omitnan');
Nmax       = min(100, Ntrials);
rewmax    = max(movmean(rewardoutcomes, Nmax, 1, 'omitnan', 'Endpoints', 'discard'), [], 1);

similar_response = sum(Data.MouseChoice(:,1) == Data.MouseChoice(:,2))/Ntrials;

% Just for the coop average value: amount of times both rewarded
coopoutcomes = all(Data.RewardOutcome == 1, 2);  % vector of shared reward
%coopoutcomes = all(Data.TrialOutcome == 1, 2);  % vector of shared reward
coopoutcomes = [coopoutcomes coopoutcomes];  % duplicate for 2 mice

cooptot = mean(coopoutcomes, 1, 'omitnan');
coopmax = max(movmean(coopoutcomes, Nmax, 1, 'omitnan', 'Endpoints', 'discard'), [], 1);

%mousewin=1;

    % mouseallreacts = NaN(Ntrials, 2);
    % for imouse = 1:2
         
    %     if iscell(respreacts{1,imouse})
    %          mouseallreacts(:,imouse) = cell2mat(respreacts{1,imouse});
    %     elseif isa(respreacts{1,imouse}, 'double')
    %          mouseallreacts (:,imouse) = respreacts{1,imouse}{1};
    %     else
    %         mouseallreacts(:,imouse) = respreacts{imouse};
    %     end
    %  end
    % trialoutcomes(trialoutcomes<0) = NaN;
    
    mouseallreacts = Data.ReactionTimes;
    trialoutcomes = all(Data.TrialOutcome == 1, 2);  % vector of shared reward
    
    mousewin = zeros(Ntrials,1);
    for iTrial = 1:Ntrials
        if coopoutcomes(iTrial) == 1
            [~, idxWin] = min([mouseallreacts(iTrial,1), mouseallreacts(iTrial,2)]);
            mousewin(iTrial) = idxWin;
        end
    end

%fprintf(mousewin);
%figure(55); plot(mousewin);

plotCompCoop(myPlots.CooperationORCompetitionPerformance,graphics, ...
    rewardavg, rewmax, rewtot, cooptot, coopmax, mousewin,similar_response)


%--------------------------------------------------------------------------
if contains( subjectName, '_')
    iscall = mode(iscongr);
    switch iscall
        case 1
            extrastr = 'Congruent';
        case 2
            extrastr = 'Random';
        case 3
            extrastr = 'Anticorrelated';
        case 4
            extrastr = 'Complementary';
    end
    title(myPlots.panhandle, ...
        {sprintf('%s %s %s', strrep( subjectName,'_',' '), date, extrastr), ' '});
end
%--------------------------------------------------------------------------
end