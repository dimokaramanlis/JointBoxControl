function plotPsychometricWeights(PsychWeightPlot, psychparams, mdlacc)

if isempty(psychparams), return, end
xvals = linspace(0, 1, 100);

cla(PsychWeightPlot);

currcols = [0 0 0; 0 1 0];
% weights = psychparams(3:end-1);
weights = psychparams(2:end);

if numel(weights) > 1
    %ftoplot =  [weights(1) * xvals; weights(2)*ones(size(xvals)); weights(3)* (1-xvals)];
    ftoplot =  [weights(1) * contrastfun(xvals); weights(2)*ones(size(xvals)) + weights(3)* socialfun(xvals)];
    
else
    ftoplot =  weights(1) *  contrastfun(xvals);
end


% ymax = max(ftoplot, [], 'all');
ymax = max(abs(ftoplot(1, :)));

% ylim(PsychWeightPlot, [-0.2 1])
% yticks(PsychWeightPlot, [-0.2 0 1] )

line(PsychWeightPlot, [0 1], [0 0], 'LineStyle', '--', 'Color','k','LineWidth', 0.5)
for ii = 1:size(ftoplot, 1)
    line(PsychWeightPlot, xvals, ftoplot(ii, :)/ymax, 'LineWidth', 1.2, 'Color', currcols(ii, :))
end
ylimvals = ylim(PsychWeightPlot);
yrange   = range(ylimvals);
text(PsychWeightPlot, 1, ylimvals(1) + yrange*0.2, 'Grating', 'HorizontalAlignment','right','Color', currcols(1, :))
text(PsychWeightPlot, 1, ylimvals(1) + yrange*0.1, 'Conspecific', 'HorizontalAlignment','right','Color',currcols(2, :))

tstr1 = 'Psychometric weights';
tstr2 = sprintf('Fit accuracy = %2.2f', mdlacc);

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

