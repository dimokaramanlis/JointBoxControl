function res = getRudimentaryAnalyses(Data, isopto, runsimple)
%GETRUDIMENTARYANALYSES Calculates rudimentary psychometric analyses
%   Updated to calculate separate psychometrics for opto and non-opto trials.

%----------------------------------------------------------------------
dtime = 0.02;
%----------------------------------------------------------------------
% Resize outputs to store separate conditions (Row 1=Normal, Row 2=Opto)
res.respcells   = cell(2,2);
res.respcons    = cell(2,2);
res.respreacts  = cell(2,2);
res.respdecis   = cell(2,2);

res.psychparams = cell(2,2); 
res.mdlaccuracy = NaN(2, 2);

for imouse = 1:2
    %----------------------------------------------------------------------
    mousechoice   = Data.MouseChoice(:,imouse);
    mousereact    = Data.ReactionTimes(:,imouse);
    mousedecide   = decideFromSpout(mousereact, mousechoice); 
    mousecontrast = Data.Contrast(:, imouse);
    mouseopto     = ~isnan(isopto(:, imouse));
    mouseopto(mouseopto) = isopto(mouseopto, imouse);
    %----------------------------------------------------------------------
    iuse = ~isnan(mousechoice);
    if all(isnan(mousechoice)), continue, end
    
    %----------------------------------------------------------------------
    % Define trial indices
    isnormaltrial = iuse & ~mouseopto;
    isoptotrial   = iuse & mouseopto;
    
    %----------------------------------------------------------------------
    % 1. Group Data (Normal)
    if nnz(isnormaltrial) > 0
        [res.respcons{1,  imouse}, ~, ic] = unique(mousecontrast(isnormaltrial));
        res.respcells{1,  imouse}         = accumarray(ic, mousechoice(isnormaltrial)==1, [], @(x) {x});
        res.respreacts{1, imouse}         = accumarray(ic, mousereact(isnormaltrial),    [], @(x) {x});
        res.respdecis{1,  imouse}         = accumarray(ic, mousedecide(isnormaltrial),    [], @(x) {x});
    end
    
    %----------------------------------------------------------------------
    % 2. Group Data (Opto)
    if nnz(isoptotrial) > 0
        [res.respcons{2, imouse}, ~, icopto] = unique(mousecontrast(isoptotrial));
        res.respcells{2, imouse}             = accumarray(icopto, mousechoice(isoptotrial)==1, [], @(x) {x});
        res.respreacts{2, imouse}            = accumarray(icopto, mousereact(isoptotrial),     [], @(x) {x});
        res.respdecis{2, imouse}             = accumarray(icopto, mousedecide(isoptotrial),    [], @(x) {x});
    end
    
    %----------------------------------------------------------------------
    % 3. Fit Psychometrics Separately
    % We loop twice: 1 = Normal, 2 = Opto
    trial_indices = {isnormaltrial, isoptotrial};
    
    for icond = 1:2
        curr_idx = trial_indices{icond};
        
        if nnz(curr_idx) > 8 % at least some observations for fitting
            iother = 2 - mod(1, imouse);
            
            % Check if we have enough social data within this specific subset
            % We look at the original 'iuse' global rows, but filtered by curr_idx
            if nnz(~isnan(sum(Data.MouseChoice(curr_idx, :), 2))) > 16
                % --- Fit Social Model ---
                xx1 = contrastfun(mousecontrast(curr_idx));
                
                otherchoice  = Data.MouseChoice(:, iother);
                otherchoice(isnan(otherchoice)) = 0;
                otherreact   = Data.ReactionTimes(:, iother);
                
                % Filter other mouse data by current mouse's current condition indices
                otherreactuse = decideFromSpout(otherreact(curr_idx), otherchoice(curr_idx));
                mousereactuse = mousedecide(curr_idx);

                xx2 = otherchoice(curr_idx);
                % Apply reaction time filter
                xx2(mousereactuse < (otherreactuse + dtime)) = 0;
                
                xx3 = xx2 .* socialfun(xx1);

                xx = [xx1 xx2 xx3];
                xx(isnan(xx)) = 0;
            else
                % --- Fit Contrast Model ---
                xx = mousecontrast(curr_idx);
            end
            
            % --- Run GLM ---
            if ~runsimple
                % Fit only on the current condition subset
                bfit = glmfit(xx, mousechoice(curr_idx)==1, 'binomial');
                res.psychparams{icond, imouse} = bfit;
            end
            
            % --- Calculate Accuracy ---
            if ~isempty(res.psychparams{icond, imouse})
                modelpred = glmval(res.psychparams{icond, imouse}, xx, 'logit') > 0.5;
                res.mdlaccuracy(icond, imouse) = mean(modelpred == (mousechoice(curr_idx)==1));
            end
        end
    end
end
%==========================================================================
end