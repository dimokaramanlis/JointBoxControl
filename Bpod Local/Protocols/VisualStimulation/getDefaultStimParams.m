function stimdesc = getDefaultStimParams(stimtype, screensize, degPerPixel, fps)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
        % chirp parameters
stimdesc = struct();
switch stimtype
    case 'OnOffSteps'
        stimdesc.Nstimframes       = 12 * fps;
        stimdesc.Ntrials           = 20;
    case 'Chirp'
        stimdesc.partdurations = [2 3 3 2 8 2 8 2 2]';
        stimdesc.freqsweep.lo_freq = 0.5;
        stimdesc.freqsweep.hi_freq = 8;
        stimdesc.ctrsweep.freq     = 2;
        stimdesc.ctrsweep.contrast = 1;
        stimdesc.Ntrials           = 10;
    case 'NaturalisticWaves'
        stimdesc.Ntrials  = 5;
        stimdesc.Nangles  = 8;
        stimdesc.thetas   = linspace(0, 360*(1-1/stimdesc.Nangles), stimdesc.Nangles);

        stimdesc.Nstixel = 2;
        Nx      = screensize(1)/stimdesc.Nstixel; % Width of the stimulus
        Ny      = screensize(2)/stimdesc.Nstixel; % Height of the stimulus
        stimdesc.Nx         = Nx;
        stimdesc.Ny         = Ny;
        stimdesc.Nfreq      = 20;
        stimdesc.Nspeed     = 20;
        stimdesc.sigma_ori  = 4;
        stimdesc.minfreq    = 0.025 * stimdesc.Nstixel * degPerPixel;
        stimdesc.maxfreq    = 0.4 * stimdesc.Nstixel * degPerPixel;
        stimdesc.minspeed   = 0.4/fps; % in Hz
        stimdesc.maxspeed   = 5/fps;   % in Hz
        stimdesc.sigmagabor = Nx/15; % Radius of the local spot
        stimdesc.contrast   = 1/3;
                % parameters for presentation
        stimdesc.Nstimframes = 5 * fps;
        Ngrayframes = 1 * 60;

        %---------------------------------------------------------------------------
        % generate and load textures
end