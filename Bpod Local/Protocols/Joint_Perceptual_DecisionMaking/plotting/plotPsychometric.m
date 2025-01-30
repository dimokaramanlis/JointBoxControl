function plotPsychometric(PsychometricPlot, mousecol, convec, respcell, psychparams)

xvals = linspace(-1, 1, 200);
% choicem2(dectimeM1-dectimeM2<-0.2)=0;
% xdata    = [allcon1(ic1)' choicem2];
if numel(psychparams) > 2
    xx  = [xvals' zeros(size(xvals))' zeros(size(xvals))'];
    xxr = [xvals'  ones(size(xvals))'   1-abs(xvals)'];
    xxl = [xvals' -ones(size(xvals))' -(1-abs(xvals)')];
else
    xx = xvals';
end

alpha = 0.05;
allresp = cellfun(@mean, respcell);
% binomial confidence intervals
allerrs = NaN(numel(respcell), 2);
for ii = 1:numel(respcell)
    [~, allerrs(ii, :)] = binofit(sum(respcell{ii}),numel(respcell{ii}), alpha);
end
lpos = NaN;
lneg = NaN;

cla(PsychometricPlot);
line(PsychometricPlot, [-1 1], [1 1]*0.5, 'Color', 'k', 'LineStyle','--', 'LineWidth',0.5)
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
%     lpos = psychparams(1);
%     lneg = psychparams(2);
    hold(PsychometricPlot,'on');
end
errorbar(PsychometricPlot, convec, allresp, allresp-allerrs(:,1), allerrs(:,2)-allresp,...
    'Marker', 'o','MarkerFaceColor', mousecol, 'CapSize',2,'LineStyle','none',...
    'MarkerEdgeColor','k','LineWidth',0.5, 'Color', mousecol)
tstr1 = sprintf('Pcychometric with %d%% CI', (1-alpha)*100);
tstr2 = sprintf('lapse blue = %2.2f, red = %2.2f', lpos, lneg);

title(PsychometricPlot, {tstr1, tstr2});

end

