function [f,J, H] = psychologistic(params, x )
%PSYCHOLOGISTIC Summary of this function goes here
%   Detailed explanation goes here
gr    = params(1); 
gl    = params(2); 
beta  = params(3:end-1);
beta  = beta(:);
gamma = params(end);
%==========================================================================
%calculate function value
insignal = x*beta + gamma;
fbef     = (1 + exp(- insignal)).^-1;
f        = (1 - (gr + gl)) * fbef + gr;
%==========================================================================
if nargout>1
    J(size(x,1), numel(params)) = 0;
    J(:,1) = -fbef + 1;
    J(:,2) = -fbef;
    J(:,end) = (f - gr) .* (1 - fbef);
    J(:,3:end-1) = J(:,end).*x;
end

% WIP
% if nargout>2
%     % get Hessian
%     H = zeros(numel(x), numel(params),  numel(params));    
%    
%     H(:, 1,     end) = fbef .* (1-fbef);
%     H(:, 1, 3:end-1) = H(:,1, end) .* x;
%     
%     H(:, 2,     end) = H(:,1, end);
%     H(:, 2, 3:end-1) = H(:,1,3:end-1);
%     
%     H(:, 3:end-1, 1) = H(:, 1, 3:end-1);
%     H(:, 3:end-1, 2) = H(:, 2, 3:end-1);
%     H(:, 3:end-1, 3:end-1) = x.* fbef .* (1 - fbef).* (2*fbef+1) * (1 - (gr + gl));
% 
% 
%     dnormpdf = J(:,2) .* (2 * eminus .* J(:,4) - 1);
%     dx = dnormpdf.*x;
%     
%     H(:,2,2) = dnormpdf;
%     H(:,2,3) = dx;
%     H(:,2,4) = J(:,2)/alpha;
%     
%     H(:,3,2) = dx;
%     H(:,3,3) = dx .* x;
%     H(:,3,4) = J(:,3)/alpha;
% 
% end

end

