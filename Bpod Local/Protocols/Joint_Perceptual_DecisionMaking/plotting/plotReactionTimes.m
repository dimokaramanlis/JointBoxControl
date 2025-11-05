function plotReactionTimes(OrientationReactionTimePlot, graphics, convec, reactcell, runsimple)
%PLOTREACTIONTIMES Summary of this function goes here
%   Detailed explanation goes here

% Reaction Times Curve

%--------------------------------------------------------------------------
cla(OrientationReactionTimePlot); 
hold(OrientationReactionTimePlot, 'on');
ymax    = 0;
edgecol = [0 0 0; graphics.optoColor];
%--------------------------------------------------------------------------
for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);
    for iplot = 1:2
        currreact = reactcell{iplot, imouse};
        currcon   = convec{iplot, imouse};
        if ~isempty(currreact)
            medreact     = cellfun(@(x) median(x,'omitnan'), currreact);
            if ~runsimple
                semreact  = cellfun(@(x) 1.4826 * mad(x(~isnan(x)), 1)/sqrt(nnz(~isnan(x))), currreact);
            else
                semreact  = cellfun(@(x) std(x(~isnan(x)))/sqrt(nnz(~isnan(x))), currreact);
            end
            
            errorbar(OrientationReactionTimePlot, currcon, medreact, semreact,...
            'Marker', 'o', 'MarkerSize',6,...
            'markerfacecolor', mousecol, 'markeredgecolor', edgecol(iplot,:), 'Color', edgecol(iplot,:),...
            'LineWidth',1, 'CapSize', 3, 'LineStyle', 'none');
            ymax = max([ymax max(medreact+semreact)]);
        end
    end
end

%--------------------------------------------------------------------------
ymax = max([ceil(ymax/0.2)*0.2 0.2]);
ylim(OrientationReactionTimePlot,   [0 ymax]);
yticks(OrientationReactionTimePlot, [0 ymax/4 ymax/2 3*ymax/4 ymax]);
%--------------------------------------------------------------------------
% think of updating ylim

end