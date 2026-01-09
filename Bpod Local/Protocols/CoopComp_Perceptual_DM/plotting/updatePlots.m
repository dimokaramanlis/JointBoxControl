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
moldwin =  [1 1] * 0.5;
%moldrew  =  [1 1] * 0.5; moldrewcoop = moldrew;
moldrew  =  0.5;
molddiseng =  0;

perfavg    = NaN(Ntrials, 2);
choiceavg  = NaN(Ntrials, 2);
disengavg  = NaN(Ntrials, 2);
winavg    = NaN(Ntrials, 2);
%rewardavg  = NaN(Ntrials, 2);
rewardavg  = NaN(Ntrials, 1);
iscongr    = zeros(Ntrials, 1);

for ii = 1:Ntrials
    iscongr(ii) =  Data.TrialSettings(ii).GUI.Dependent;
    mcurr       =  Data.TrialOutcome(ii, :);
    chcurr      =  Data.MouseChoice(ii, :);
    %rewout      =  Data.RewardOutcome(ii, :);

    dcurr         = isnan(chcurr);
    molddiseng    = beta * molddiseng + (1 - beta) * dcurr;
    disengavg(ii, :) = molddiseng;

    %--------------------------------------------------------------------------
    %PERFORMANCE MOVING AVERAGE
    % abort invalid trials
    if any(mcurr<0), continue,  end
    % regress to 0.5 when task setting changes... ???????????
%     if ~isequal(isnan(mcurr), isnan(moldperf))
%         moldperf = ~isnan(mcurr) * 0.5;
%     end


%instead of all of this, maybe just jump nan trials?? TEST NEXT
    for this_mouse = 1:length(moldperf)
        if isnan(moldperf(this_mouse)) && ~isnan(mcurr(this_mouse))           
            last_notnan = find(~isnan(perfavg(:,this_mouse)),1,'last');
            if isempty(last_notnan)
                moldperf(this_mouse) = 0.5;
            else
                moldperf(this_mouse) = perfavg(last_notnan,this_mouse);
            end
        end
    end
    
    moldperf    = beta * moldperf + (1 - beta) * mcurr;
    perfavg(ii, :) = moldperf;

    %--------------------------------------------------------------------------
    %CHOICE MOVING AVERAGE
    % abort invalid trials
    if all(isnan(chcurr)), continue,  end
    chcurr = (chcurr+1)/2;
    % regress to 0.5 when task setting changes...
%     if ~isequal(isnan(chcurr), isnan(moldchoice))
%         moldchoice = ~isnan(chcurr) * 0.5;
%     end
    
    for this_mouse = 1:length(moldchoice)
        if isnan(moldchoice(this_mouse)) && ~isnan(chcurr(this_mouse))           
            last_nonnan = find(~isnan(choiceavg(:,this_mouse)),1,'last');
            if isempty(last_nonnan)
                moldchoice(this_mouse) = 0.5;
            else
                moldchoice(this_mouse) = choiceavg(last_nonnan,this_mouse);
            end
        end
    end
    moldchoice    = beta * moldchoice + (1 - beta) * chcurr;
    choiceavg(ii, :) = moldchoice;
    
    %--------------------------------------------------------------------------
    %COOPERATION MOVING AVERAGE
    trialout = Data.TrialOutcome(ii, :); %it is not real cooperation, but wheter both were coreect. FIX AFTER FIGURING!!
    rewout = all(trialout == 1);
    
    if any(isnan(trialout)); continue,  end

    moldrew    = beta * moldrew + (1 - beta) * rewout;
    rewardavg(ii, :) = moldrew;
    
    %--------------------------------------------------------------------------
    %WINNING MOVING AVERAGE
    mouseallreacts = Data.ReactionTimes(ii, :);
    winout = [nan,nan];
    if rewout == 1
        if mouseallreacts(1) < mouseallreacts(2)
            winout(1)=1;
            winout(2)=0;
        else
            winout(1)=0;
            winout(2)=1;
        end
    else % one was wrong
        continue        
    end
    
    moldwin    = beta * moldwin + (1 - beta) * winout;
    winavg(ii, :) = moldwin;
    
    
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
% PLOTTING INITIATION TIME PER TRIAL
initiationtimes =  Data.InitiationTime;
if isfield( Data, 'isSpontaneous')
    isspontaneous   =  Data.isSpontaneous;
else
    isspontaneous = false([size(initiationtimes,1),1]);
end
plotInitiationTimes(myPlots.initationTimePlot, graphics, initiationtimes, isspontaneous)

%--------------------------------------------------------------------------
% PLOTTING DECISION TIME PER TRIAL
decidetimes =  Data.DecisionTimes;
decidetimes(isnan( Data.MouseChoice)) = NaN;
lims_y=2;
plotChoiceTimes(myPlots.decisionTimePlot, graphics, decidetimes,lims_y);

%--------------------------------------------------------------------------
% PLOTTING TIME TO SPOUT PER TRIAL
choicetimes =  Data.ReactionTimes;
choicetimes(isnan( Data.MouseChoice)) = NaN;
lims_y=3;
plotChoiceTimes(myPlots.choiceTimePlot, graphics, choicetimes,lims_y);

%--------------------------------------------------------------------------
% PLOTTING PERFORMANCE PER TRIAL
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
% PLOTTING CHOICE PER TRIAL
choicetot = sum( Data.MouseChoice>0, 1);
choicetot = choicetot./sum(abs( Data.MouseChoice)>0, 1);

rplus  = sum( Data.RewardAmount.*( Data.MouseChoice>0).*(trialoutcomes>0), 1, 'omitnan');
rminus = sum( Data.RewardAmount.*( Data.MouseChoice<0).*(trialoutcomes>0), 1, 'omitnan');
plotTaskEngagement(myPlots.taskEngagementPlot, graphics, choiceavg, choicetot, disengavg, [rplus;rminus]);

%--------------------------------------------------------------------------
% PLOTTING PSYCHOMETRIC CURVE (CHOICE X CONTRAST) AND GLM WEIGHTS
for imouse = 1:2
    % plots
    mousecol = graphics.mouseColor(imouse, :);
    
    if isempty(respcells{imouse}), continue, end
    plotPsychometric(myPlots.PsychometricPlot(imouse), mousecol, ...
        respcons{imouse}, respcells{imouse}, psychparams{imouse}, runsimple)
    plotPsychometricWeights(myPlots.WeightPlot(imouse), psychparams{imouse}, mdlaccuracy(imouse))
end

%--------------------------------------------------------------------------
% PLOTTING DECISION AND REACTION TIME PER CONTRAST
lims_y=4;
plotReactionTimes(myPlots.OrientationReactionTimePlot, graphics, respcons, respreacts ,runsimple,lims_y)
plotReactionTimes(myPlots.OrientationDecisionTimePlot, graphics, respcons, respdecis, runsimple,lims_y)

%--------------------------------------------------------------------------
% PLOTTING COOPERATION AND COMPETITION DATA
rewardoutcomes =  Data.RewardOutcome;            %Both rewarded
trialoutcomes = all(Data.TrialOutcome == 1, 2);  % Both correct
Nmax       = min(100, Ntrials);

similar_response = sum(Data.MouseChoice(:,1) == Data.MouseChoice(:,2))/Ntrials; %how many times mice did the same

%Amount of time each mouse was rewarded
rewtot    = mean(rewardoutcomes, 1, 'omitnan');
rewmax    = max(movmean(rewardoutcomes, Nmax, 1, 'omitnan', 'Endpoints', 'discard'), [], 1); %how many times both mice were rewarded
%this gives m1 m2

%Amount of wins
wintot    = mean(winavg, 1, 'omitnan');
winmax    = max(movmean(winavg, Nmax, 1, 'omitnan', 'Endpoints', 'discard'), [], 1); %how many times both mice were rewarded
%this gives m1 m2

% Amount of times mice cooperated (for now: correct trials)
cooptot    = mean(trialoutcomes, 1, 'omitnan');
coopmax    = max(movmean(trialoutcomes, Nmax, 1, 'omitnan', 'Endpoints', 'discard'), [], 1); %how many times both mice were correct
%this gives 1 value

%Amount of time both mice were rewarded
bothrew = all(Data.RewardOutcome == 1, 2);
bothtot    = mean(bothrew, 1, 'omitnan');
bothmax    = max(movmean(bothrew, Nmax, 1, 'omitnan', 'Endpoints', 'discard'), [], 1); %how many times both mice were rewarded
%this gives 1 value
    
    mouseallreacts = Data.ReactionTimes;       
    
    mousewin = zeros(Ntrials,1);
    for iTrial = 1:Ntrials
        if trialoutcomes(iTrial) == 1 %if both correct
            [~, idxWin] = min([mouseallreacts(iTrial,1), mouseallreacts(iTrial,2)]); %who was faster
            mousewin(iTrial) = idxWin;
        end
    end

plotCompCoop(myPlots.CooperationORCompetitionPerformance,graphics, ...
    rewardavg, winavg, winmax, wintot, cooptot, coopmax, mousewin, similar_response, bothtot, bothmax, rewtot,rewmax)

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