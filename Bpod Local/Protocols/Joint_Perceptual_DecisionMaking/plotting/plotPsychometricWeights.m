function plotPsychometricWeights(PsychWeightPlot, psychparams, mdlacc)

emptyvals = cellfun(@isempty, psychparams);
if emptyvals(1), return, end
xvals = linspace(0, 1, 100);

cla(PsychWeightPlot);

currcols = [0 0 0; 0 1 0];

ftoplot = cell(2, 1);
for iplot = 1:2
    if ~emptyvals(iplot)
        weights = psychparams{iplot}(2:end);
        if numel(weights) > 1
            ftoplot{iplot} = [weights(1) * contrastfun(xvals); ...
                weights(2)*ones(size(xvals)) + weights(3)* socialfun(xvals)];
        else
            ftoplot{iplot} = weights(1) *  contrastfun(xvals);
        end
    end
end

ymax = max(abs(ftoplot{1}), [], 'all');

line(PsychWeightPlot, [0 1], [0 0], 'LineStyle', '--', 'Color','k','LineWidth', 0.5)
linestyles = {'-', '--'};
for iplot = 1:2
    if ~emptyvals(iplot)
        for ii = 1:size(ftoplot{iplot}, 1)
            line(PsychWeightPlot, xvals, ftoplot{iplot}(ii, :)/ymax, ...
                'LineWidth', 1.2, 'Color', currcols(ii, :), 'LineStyle', linestyles{iplot})
        end
    end
end
ylimvals = ylim(PsychWeightPlot);
yrange   = range(ylimvals);
text(PsychWeightPlot, 1, ylimvals(1) + yrange*0.2, 'Grating', 'HorizontalAlignment','right','Color', currcols(1, :))
text(PsychWeightPlot, 1, ylimvals(1) + yrange*0.1, 'Conspecific', 'HorizontalAlignment','right','Color',currcols(2, :))

tstr1 = 'Psychometric weights';
tstr2 = sprintf('fit acc. = %2.2f/%2.2f (opto)', mdlacc(1), mdlacc(2));

title(PsychWeightPlot, {tstr1, tstr2});


% 
% 
% if ~isempty(psychparams)
%     psychvals  = psychologistic(psychparams, xx);
%     line(PsychWeightPlot, xvals, psychvals, 'Color', 'k', 'LineWidth', 1,...
%         'Linestyle','--')
%     
%     % only if there is a social fit we need to plot more psychometrics
%     if  numel(psychparams) > 4
%         psychvalsr = psychologistic(psychparams, xxr);
%         psychvalsl = psychologistic(psychparams, xxl);
%         line(PsychWeightPlot, xvals, psychvalsr, 'Color', 'b', 'LineWidth', 0.5)
%         line(PsychWeightPlot, xvals, psychvalsl, 'Color', 'r', 'LineWidth', 0.5)
%     end
%     lpos = psychparams(1);
%     lneg = psychparams(2);
%     hold(PsychWeightPlot,'on');
% end
% errorbar(PsychWeightPlot, convec, allresp, allresp-allerrs(:,1), allerrs(:,2)-allresp,...
%     'Marker', 'o','MarkerFaceColor', mousecol, 'CapSize',0,'LineStyle','none',...
%     'MarkerEdgeColor','k','LineWidth',0.5, 'Color', mousecol)
% tstr1 = sprintf('Pcychometric with %d%% CI', (1-alpha)*100);
% tstr2 = sprintf('lapse blue = %2.2f, red = %2.2f', lpos, lneg);
% 
% title(PsychWeightPlot, {tstr1, tstr2});

end

