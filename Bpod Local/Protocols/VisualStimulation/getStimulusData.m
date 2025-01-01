function [stimpara, PTB] = getStimulusData(stimtype, PTB, degPerPixel)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
fps = round(1/mean(PTB.ifis));
screensize = PTB.windowrects(1, 3:4);
stimdesc = getDefaultStimParams(stimtype, screensize, degPerPixel, fps);
stimpara = struct();
fprintf('Loading %s... ', stimtype); tic;
switch stimtype
    case 'Chirp'
        %---------------------------------------------------------------------------
        % generate chirp
        [chrptrace,      ~]  = generateChripTrace(stimdesc, fps);
        stimpara.chrptrace   = chrptrace;
        stimpara.graytime    = 0;
        stimpara.Tstim       = sum(stimdesc.partdurations);
        stimpara.Nstimtrials = stimdesc.Ntrials;
        pulsetrace = zeros(size(chrptrace));
        induse = [0;cumsum(stimdesc.partdurations(1:end-1))]*fps+1;
        pulsetrace(induse' + (0:2)') = 1;
        stimpara.pulsetrace  = pulsetrace;
        %---------------------------------------------------------------------------
    case 'NaturalisticWaves'
        %---------------------------------------------------------------------------
        % generate or load stimulus
        texturepath = 'C:\BoxSettings\texturestimulus.mat';
         if ~exist(texturepath, 'file')
            texturedata = makeNaturalisticWaveStimulus(texturepath, stimdesc);
        else
            texturedata = load(texturepath);
         end
        %---------------------------------------------------------------------------
        % generate texture
        PTB.textureIndex = zeros(stimdesc.Nstimframes, stimdesc.Nangles, 2);
        for it = 1:stimdesc.Nstimframes
            for iangle = 1:stimdesc.Nangles
                currtex = kron(texturedata.stimulus(:,:,it, iangle), ones(texturedata.Nstixel, 'uint8'));
                for iscreen = 1:numel(PTB.windows)
                    PTB.textureIndex(it, iangle, iscreen) = ...
                        Screen('MakeTexture', PTB.windows(iscreen), currtex);
                end
            end
        end
        
        stimpara.graytime    = 1;
        stimpara.Tstim       = stimdesc.Nstimframes / fps;
        stimpara.Nstimtrials = stimdesc.Nangles * stimdesc.Ntrials;
        stimpara.Nstimframes = stimdesc.Nstimframes;
        stimpara.Ngrayframes = round(stimpara.graytime*fps);
        % oroginal rng before 12/12/2023 was rng(1);
        randorder = NaN(stimpara.Nstimtrials, 1);
        for ii = 1:stimdesc.Ntrials
            randorder((ii - 1) * stimdesc.Nangles + (1:stimdesc.Nangles)) = ...
                randperm(stimdesc.Nangles);
        end
        stimpara.randorder  = randorder;
        stimpara.currstimid = 0;
        %---------------------------------------------------------------------------
end

fprintf('Done! Took %2.2fs\n', toc); 

end