function stimulus = generateGaborNoiseStimulus(stimpara, Nframes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Ngratings   = stimpara.Nfreq * stimpara.Nspeed;
% spatFreqs   = linspace( stimpara.minfreq, stimpara.maxfreq,   stimpara.Nfreq); % Spatial frequencies (cycles per stixel)
% driftSpeeds = linspace(stimpara.minspeed, stimpara.maxspeed, stimpara.Nspeed);

spatFreqs   = logspace( log10(stimpara.minfreq), log10(stimpara.maxfreq),   stimpara.Nfreq); % Spatial frequencies (cycles per stixel)
driftSpeeds = logspace(log10(stimpara.minspeed), log10(stimpara.maxspeed), stimpara.Nspeed);
[ffs, vvs] = meshgrid(spatFreqs, driftSpeeds);


%Generate generic grid of NsubMax subunits
RadMax = floor(max(roots([3 3 1-Ngratings])))+1;

%Generate generic grid of NsubMax subunits
pts1 = squareGrid(RadMax * [-1 -1 1 1],           [0 0], [1 sqrt(3)]);
pts2 = squareGrid(RadMax * [-1 -1 1 1], [1/2 sqrt(3)/2], [1 sqrt(3)]);
pts  = [pts1;pts2];
arad = sqrt(2/(sqrt(3)*Ngratings/(stimpara.Nx * stimpara.Ny)));
cpts = [stimpara.Nx stimpara.Ny]/2 + pts * arad;
cpts(cpts(:,1)<-arad, :) = [];
cpts(cpts(:,2)<-arad, :) = [];
cpts(cpts(:,1)>stimpara.Nx + arad, :) = [];
cpts(cpts(:,2)>stimpara.Ny +arad, :) = [];

%radius = arad; % Radius of the local spot
orientation = stimpara.orientation + randn(Ngratings,1)*stimpara.sigma_ori;



% Create a 3D array to store the pink spectrum movie
pinkSpectrumMovie = gpuArray.zeros(stimpara.Ny, stimpara.Nx, Nframes, 'single');
phaseinit         = gpuArray.rand(Ngratings,1,'single') * 360;
allcents          = cpts(randperm(size(cpts,1), Ngratings),:) + randn(Ngratings,2)*stimpara.sigmagabor/20;
allcents          = gpuArray(single(allcents));
wtsuse            = 1./(ffs(:).*vvs(:));
wtsuse            = wtsuse/sum(wtsuse);
wtsuse            = gpuArray(single(wtsuse));

tic;
% Generate the pink spectrum movie
for t = 1:Nframes
    
    % Update the phase of the drifting gratings
    %phase = mod(t * vvs(:) *360/60, 360) + phaseinit;
    phase = t * vvs(:)*360 + phaseinit;

     maskedGratings = gaborPatches(single(gpuArray(stimpara.Nx)), single(gpuArray(stimpara.Ny)),...
         single(gpuArray(ffs(:))), orientation, phase(:), allcents, stimpara.sigmagabor);

     pinkSpectrumMovie(:, :, t) = pinkSpectrumMovie(:, :, t) + ...
         reshape(maskedGratings * wtsuse,[stimpara.Ny, stimpara.Nx]);
     
end
toc;
% default is 0.3
pinkSpectrumMovie = stimpara.contrast*pinkSpectrumMovie/std(pinkSpectrumMovie,[],'all');
pinkSpectrumMovie = gather(pinkSpectrumMovie);
stimulus          = (pinkSpectrumMovie+1)*255/2;
stimulus          = uint8(stimulus);



end