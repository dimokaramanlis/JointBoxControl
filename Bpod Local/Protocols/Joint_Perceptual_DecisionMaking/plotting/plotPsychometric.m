function plotPsychometric(PsychometricPlot, mousecol, convec, respcell, psychparams, runsimple)
%==========================================================================
% calculate psychometric
xvals = linspace(-1, 1, 100);
if numel(psychparams) > 2
    xx  = [contrastfun(xvals)' zeros(size(xvals))' zeros(size(xvals))'];
    xxr = [contrastfun(xvals)'  ones(size(xvals))' socialfun(xvals)'];
    xxl = [contrastfun(xvals)' -ones(size(xvals))' -socialfun(xvals)'];
else
    xx =  contrastfun(xvals)';
end
%==========================================================================
% we prepare the plot
cla(PsychometricPlot);
line(PsychometricPlot, [-1 1], [1 1]*0.5, 'Color', 'k', 'LineStyle','--', 'LineWidth',0.5)
line(PsychometricPlot, [0 0], [0 1], 'Color', 'k', 'LineStyle','--', 'LineWidth',0.5)
%==========================================================================
% we plot psychometric
if ~isempty(psychparams)
    psychvals  = glmval(psychparams, xx, 'logit');
    line(PsychometricPlot, xvals, psychvals, 'Color', [0 0 0 0.6], 'LineWidth', 1,...
        'Linestyle','-')
    
    % only if there is a social fit we need to plot more psychometrics
    if  numel(psychparams) > 2
        psychvalsr = glmval(psychparams, xxr, 'logit');
        psychvalsl = glmval(psychparams, xxl, 'logit');
        line(PsychometricPlot, xvals, psychvalsr, 'Color', [0 0 1 0.4], 'LineWidth', 0.5)
        line(PsychometricPlot, xvals, psychvalsl, 'Color', [1 0 0 0.4], 'LineWidth', 0.5)
    end
    hold(PsychometricPlot,'on');
end
%==========================================================================
% we plot the points
alpha   = 0.05;
edgecol = [0 0 0; mousecol(2, :)];
for iplot = 1:2

    % calculate confidence intervals
    allresp = cellfun(@mean, respcell{iplot});
    % binomial confidence intervals
    allerrs = NaN(numel(respcell{iplot}), 2);
    if ~runsimple
        for ii = 1:numel(respcell{iplot})
            [~, allerrs(ii, :)] = binofit(sum(respcell{iplot}{ii}),numel(respcell{iplot}{ii}), alpha);
        end
    end

    errorbar(PsychometricPlot, convec{iplot}, allresp, allresp-allerrs(:,1), allerrs(:,2)-allresp,...
        'Marker', 'o','MarkerFaceColor', mousecol(1, :), 'CapSize',2,'LineStyle','none',...
        'MarkerEdgeColor',edgecol(iplot,:),'LineWidth',0.5, 'Color', edgecol(iplot,:))

end
%==========================================================================
tstr1 = sprintf('Pcychometric with %d%% CI', (1-alpha)*100);
title(PsychometricPlot, tstr1);
%==========================================================================
end

