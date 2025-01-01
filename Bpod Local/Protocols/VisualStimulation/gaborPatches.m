function gabors = gaborPatches(xpix, ypix, spatFreq, orientation, phase, centers, sigma)
% tic;
% Ngratings = numel(spatFreq);
% [xx, yy] = meshgrid(1:xpix, 1:ypix);
% lambda = 1 ./ spatFreq;
% lambda = reshape(lambda, [1, 1, Ngratings]);
% phase  = reshape(phase, [1, 1, Ngratings]);
% 
% xTheta = xx * cosd(orientation) + yy * sind(orientation);
% 
% gratings  = cos(2 * pi * xTheta ./ lambda + deg2rad(phase));
% gaussians = exp(-((xx(:) - reshape(centers(:,1),[1,Ngratings])).^2 +...
%     (yy(:) - reshape(centers(:,2),[1,Ngratings])).^2) / (2 * sigma^2));
% gabors = gratings.*reshape(gaussians, size(gratings));  
% toc;

Ngratings = numel(spatFreq);
[xx, yy] = meshgrid(1:xpix, 1:ypix);
lambda   = 1 ./ single(spatFreq);
lambda   = reshape(lambda, [1, Ngratings]);
phase    = reshape(phase, [1, Ngratings]);
xx       = reshape(xx, [ypix*xpix, 1]);
yy       = reshape(yy, [ypix*xpix, 1]);

xTheta    = xx .* cosd(orientation') + yy .* sind(orientation');
gratings  = cos(2 * pi * xTheta ./ lambda + deg2rad(phase));
gaussians = exp(-((xx - centers(:,1)').^2 + (yy - centers(:,2)').^2) / (2 * sigma^2));
gabors    = gratings.*gaussians;  


end