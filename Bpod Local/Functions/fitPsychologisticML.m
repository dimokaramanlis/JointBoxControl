function [params,res] = fitPsychologisticML(xvals, choices, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%==========================================================================
%unwrap and standardize variables
choices = choices(:);
Ncov    = size(xvals,2);
%==========================================================================
if nargin>2
    guess = varargin{1};
    defaultguess = false;
else
    defaultguess = true;
end

if (numel(guess)~= (Ncov+3)) || defaultguess
    guess = [0 0 ones(1,Ncov) 0];
end
%==========================================================================
lb = [0  0   -Inf(1,Ncov+1)];
ub = [1  1    Inf(1,Ncov+1)];
% lb = [0  0   -5*ones(1,Ncov+1)];
% ub = [1  1    5*ones(1,Ncov+1)];

%==========================================================================
% A = [1 1 0 0];
% b = [1];
%==========================================================================
%optimize function
foptim = @(p) logisticOptim(p,xvals,choices);

if isnan(foptim(guess)) || isinf(foptim(guess))
    params = []; return;
end

options= optimoptions('fmincon','Algorithm','interior-point',...
    'Display','off','SpecifyObjectiveGradient',true, 'HessianFcn', [],...
    'CheckGradients', false);

[params,res] = fmincon(foptim, guess,[],[],[],[],lb,ub,[],options);  

%==========================================================================
end

function [f, g] = logisticOptim(params, xx ,yy)
% Calculate objective f

[lf, lg] = psychologistic(params, xx);

%Nr       = sum(yy);

f = -yy'*log(lf) - (1-yy')*log(1-lf); %objective f

if nargout > 1
    g =  -(yy./lf)'*lg + ((1-yy)./(1-lf))'*lg ;
end

% if nargout > 2
%     H = a;
% end

end