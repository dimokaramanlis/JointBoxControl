function dsave = makeNaturalisticWaveStimulus(dpath, stimdesc)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

dsave=struct();
dsave.stimulus = zeros(stimdesc.Ny, stimdesc.Nx, stimdesc.Nstimframes, stimdesc.Nangles, 'uint8');
for iangle = 1:stimdesc.Nangles
    stimdesc.orientation = stimdesc.thetas(iangle);
    dsave.stimulus (:, :, :, iangle) = generateGaborNoiseStimulus(stimdesc, stimdesc.Nstimframes);
end
dsave.Nstixel = stimdesc.Nstixel;
save(dpath, '-struct','dsave')

end