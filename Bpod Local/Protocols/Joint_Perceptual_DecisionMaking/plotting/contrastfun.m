function yy = contrastfun(xx)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% yy = sqrt(abs(xx)) .* sign(xx);
yy = (1-(1-abs(xx)).^4).* sign(xx);
end