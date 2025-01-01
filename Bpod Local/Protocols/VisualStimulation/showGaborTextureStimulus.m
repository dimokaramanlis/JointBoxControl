function showGaborTextureStimulus(Ntrials, windows, windowrects, ops)

fprintf('Loading gabor textures, please be patient...\n');
% Open an on screen window
Nscreens    = numel(windows);
ifis        = zeros(Nscreens, 1);

% setup a gray screen while waiting
for iscreen = 1:Nscreens
    ifis(iscreen) = Screen('GetFlipInterval', windows(iscreen)); 
    Screen('FillRect', windows(iscreen), 0.5, windowrects(iscreen,:));
    Screen('Flip', windows(iscreen));
end

ifim = mean(ifis);
fps  = 1/ifim;
%---------------------------------------------------------------------------
ops.degPerPixel  = 92/1280;
Nstixel          = 4;

Nx = ceil(windowrects(1,3)/Nstixel); % Width of the stimulus
Ny = ceil(windowrects(1,4)/Nstixel); % Height of the stimulus
%---------------------------------------------------------------------------
% parameters for presentation
Nstimframes = 5 * 60;
Ngrayframes = 1 * 60;
Nangles     = 8;
%---------------------------------------------------------------------------
% setup random order
rng(1); gpurng(1);
listrand = zeros(Nangles, Ntrials);
for itrial = 1:Ntrials
    listrand(:, itrial) = randperm(Nangles, Nangles);
end
listrand = reshape(listrand, [Nangles*Ntrials, 1]);
%---------------------------------------------------------------------------
% parameters for texture
stimpara.Nx         = Nx;
stimpara.Ny         = Ny;
stimpara.Nfreq      = 20;
stimpara.Nspeed     = 20;
stimpara.sigma_ori  = 4;
stimpara.minfreq    = 0.025 * Nstixel * ops.degPerPixel;
stimpara.maxfreq    = 0.4 * Nstixel * ops.degPerPixel;
stimpara.minspeed   = 0.4/fps; % in Hz
stimpara.maxspeed   = 5/fps;   % in Hz
stimpara.sigmagabor = Nx/15; % Radius of the local spot
stimpara.contrast   = 1/3;
%---------------------------------------------------------------------------
% generate and load textures
thetas       = linspace(0, 360*(1-1/Nangles), Nangles);
textureIndex = zeros(Nstimframes * Nangles, 2);
for iangle = 1:Nangles
    stimpara.orientation = thetas(iangle);
    currstim             = generateGaborNoiseStimulus(stimpara, Nstimframes);
    % load texture
    for ii = 1:Nstimframes
        currtex = kron(currstim(:,:,ii), ones(Nstixel, 'uint8'));
        for iscreen = 1:Nscreens
            textureIndex((iangle-1) * Nstimframes + ii, iscreen) = Screen('MakeTexture', windows(iscreen), currtex);
        end
    end
end
fprintf('Loading done, enjoy the show!\n');
%%
%---------------------------------------------------------------------------
% start presentation
Nframestot = Nstimframes + Ngrayframes;
itheta = 0;

vbls = zeros(Nscreens, 1);
for iscreen = 1:Nscreens
    vbls(iscreen)          = Screen('Flip', windows(iscreen));
end

for frameCounter = 0:Nangles*Nframestot*Ntrials-1

    frameidx = mod(frameCounter, Nframestot);
    if frameidx==0
        itheta    = itheta+1;
        thetashow = listrand(itheta);
        %thetashow = mod(itheta-1, Nangles) + 1;
    end

    if frameidx<Nstimframes
        % Draw noise texture to the screen
        for iscreen = 1:Nscreens
            Screen('DrawTexture', windows(iscreen), textureIndex((thetashow-1) * Nstimframes + frameidx+1, iscreen));
        end
    else
        for iscreen = 1:Nscreens
            Screen('FillRect', windows(iscreen), 0.5, windowrects(iscreen,:));
        end
    end
    

    % Flip to the screen on the next vertical retrace
    for iscreen = 1:Nscreens
    % Flip to the screen on the next vertical retrace
        vbls(iscreen) = Screen('Flip', windows(iscreen), vbls(iscreen) + 0.5 * ifim);
    end
end
%--------------------------------------------------------------------------
% go back to gray
for iscreen = 1:Nscreens
    Screen('FillRect', windows(iscreen), 0.5, windowrects(iscreen,:));
    Screen('Flip', windows(iscreen),vbls(iscreen) + (30 - 0.5) * ifim);
end
%--------------------------------------------------------------------------

end
