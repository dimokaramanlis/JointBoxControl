function [q,varargout]=quantilese(x,p,a)
% QUANTILESE calculates quantiles and standard errors or confidence intervals
%
% Usage:
%  [q,se]=quantilese(x,p)
%  [q,ql,qu]=quantilese(x,p,a)
%
% Inputs:
%  X is an array of real numeric data
%  P is an array of values between 0 and 1
%  A (optional) is a scalar between 0 and 1
%
% Outputs:
%  Q is an array of the same size as P, with Q(i) being the P(i)th quantile of
%    the data in X.  If X is of length N then Q=XS(round(N*P)) where XS is the
%    sorted X.  Note that this differs from the value returned by PERCENTILE in
%    the Statistics toolbox, which is obtained by linear interpolation of the
%    (N*P+1/2)th value of X.
%  SE is an array of the same size as P, with standard errors of the quantiles
%    in Q calculated by the Maritz-Jarrett method (see below).  SE is returned
%    if input A is not specified.
%  QL and QU are arrays of the same size as P, being lower and upper bounds of
%    the confidence interval of Q for level A.
%  
% Examples:
%  x=rand(1000,1);
%  [q,se]=quantilese(x,[0.9,0.99])
%  [q,ql,qu]=quantilese(x,[0.9,0.99],0.95)
%
% Method:
%  The Maritz-Jarrett method estimates the distribution of the quantile Q with 
%  Prob(Q<=x) = betainc(I/N,AL,BE) where I is the index of the largest value in
%  X not exceeding x, and AL=M-1 and BE=N-M.  Set
%  W(i)=betainc(i/N,AL,BE)-betainc((i-1)/N,AL,BE), and Ck=sum(W(i)*XS(i))
%  Then the standard error is SE=sqrt(C2-C1^2).  The confidence intervals are
%  determined by normal approximation.
%
% References:
%  Maritz, J.S. and Jarrett, R.G., "A note on estimating the variance of the
%  sample median", Journal of the American Statistical Association v73 n361 (Mar
%  1978) pp194-196.
%
% See also:
%  PERCENTILE (Statistics toolbox)

% Author:
%  Ben Petschel
% Version history:
%  16/6/2011 - initial release

if nargin<2
  error('quantilese:nargin','At lease one input argument is required');
else
  getci = nargin>2; % if 3 inputs, get confidence intervals
end;
if ~isnumeric(x)
  error('quantilese:xtype','Input X must be a numeric array');
end;
if ~all(isfinite(p)) || ~isreal(p) || any(p<0) || any(p>1)
  error('quantilese:pval','Input P must be a numeric array with values between 0 and 1');
end;
if getci
  if ~isscalar(a) || ~isfinite(a) || ~isreal(a) || a<0 || a>1
    error('quantilese:aval','Input A must be a scalar between 0 and 1');
  end;
end;

n = numel(x);
m = max(1,min(n,round(n*p)));

xs = sort(x(:));
q = reshape(xs(m),size(p));

se = zeros(size(p));
for i=1:numel(p)
  % use betainc rather than betacdf so that stats toolbox is not required
  wc = betainc((0:n)'/n,m(i)-1,n-m(i));
  w = diff(wc);

  se(i) = sqrt(sum(w.*xs.^2)-sum(w.*xs)^2);
end;

if getci
  nl = norminv((1-a)/2);
  nu = norminv((1+a)/2);
  ql = q+se*nl;
  qu = q+se*nu;
  varargout{1} = ql;
  varargout{2} = qu;
else
  varargout{1} = se;
end;
