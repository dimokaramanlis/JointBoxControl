function res = getRudimentaryAnalyses(Data, isopto, runsimple)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%----------------------------------------------------------------------
dtime = 0.02;
%----------------------------------------------------------------------
res.respcells   = cell(2,2);
res.respcons    = cell(2,2);
res.respreacts  = cell(2,2);
res.respdecis   = cell(2,2);

res.psychparams = cell(1,2);
res.mdlaccuracy = NaN(1, 2);

for imouse = 1:2
    %----------------------------------------------------------------------
    mousechoice   = Data.MouseChoice(:,imouse);
    mousereact    = Data.ReactionTimes(:,imouse);
    mousedecide   = decideFromSpout(mousereact, mousechoice); % Data.DecisionTimes(:,imouse);
    mousecontrast = Data.Contrast(:, imouse);
    mouseopto     = ~isnan(isopto(:, imouse));
    mouseopto(mouseopto) = isopto(mouseopto, imouse);
    %----------------------------------------------------------------------
    iuse = ~isnan(mousechoice);
    if all(isnan(mousechoice)), continue, end
    %----------------------------------------------------------------------
    % normal data
    [res.respcons{1,  imouse}, ~, ic] = unique(mousecontrast(iuse & ~mouseopto));
    res.respcells{1,  imouse}         = accumarray(ic, mousechoice(iuse & ~mouseopto), [], @(x) {x});
    res.respreacts{1, imouse}         = accumarray(ic, mousereact(iuse  & ~mouseopto),    [], @(x) {x});
    res.respdecis{1,  imouse}         = accumarray(ic, mousedecide(iuse & ~mouseopto),    [], @(x) {x});
    %----------------------------------------------------------------------
    % opto data
    [res.respcons{2, imouse}, ~, icopto] = unique(mousecontrast(iuse & mouseopto));
    res.respcells{2, imouse}             = accumarray(icopto, mousechoice(iuse & mouseopto)==1, [], @(x) {x});
    res.respreacts{2, imouse}            = accumarray(icopto, mousereact(iuse  & mouseopto),    [], @(x) {x});
    res.respdecis{2, imouse}             = accumarray(icopto, mousedecide(iuse & mouseopto),    [], @(x) {x});
    %----------------------------------------------------------------------
    iother      = 2-mod(1,imouse);
    if nnz(iuse) > 8 % at least some observations for fitting
        if nnz(~isnan(sum( Data.MouseChoice(iuse,:),2))) > 16
            % fit social model
            xx1 = contrastfun(mousecontrast(iuse));
            otherchoice  = Data.MouseChoice(:, iother);
            otherchoice(isnan(otherchoice)) = 0;
            otherreact   =  Data.ReactionTimes(:, iother);
            otherreactuse = decideFromSpout(otherreact(iuse), otherchoice(iuse));
            mousereactuse = mousedecide(iuse);

            xx2 = otherchoice(iuse);
            xx2(mousereactuse < (otherreactuse + dtime)) = 0;
            
            xx3 = xx2.* socialfun(xx1);

            xx = [xx1 xx2 xx3];
            xx(isnan(xx)) = 0;
        else
            % fit contrast model
            xx = mousecontrast(iuse);
        end
        %temporary fix 
        if ~runsimple
            bfit = glmfit(xx, mousechoice(iuse)==1, 'binomial');
            res.psychparams{imouse} =bfit;
        end
%         psychparams{imouse} = fitPsychologisticML(xx, mousechoice(iuse)==1, myPlots.psychparams{imouse});
        if ~isempty(res.psychparams{imouse})
            modelpred   = glmval(res.psychparams{imouse}, xx, 'logit') > 0.5;
            res.mdlaccuracy(imouse) = mean(modelpred == (mousechoice(iuse)==1));
        end
    end       
end
%==========================================================================
end