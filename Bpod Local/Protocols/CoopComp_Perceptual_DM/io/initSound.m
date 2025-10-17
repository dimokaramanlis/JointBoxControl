function PPA = initSound()
% Init Psych Sound, Our Cues, and Microphone

InitializePsychSound(1);
PPA.nrchannels = 2;
PPA.freq = 48000;
% set player properties
PPA.repetitions=1;
PPA.starttime=0;
PPA.waitForDeviceStart = 1;
devices = PsychPortAudio('GetDevices');
target_device_idxs=[];
recording_device = 0;
for i=1:size(devices,2)
    current_APIName=getfield(devices(i),'HostAudioAPIName'); %#ok<GFLD>
    current_deviceName = getfield(devices(i),'DeviceName'); %#ok<GFLD>
    if contains(current_APIName,'Windows WASAPI') && contains(current_deviceName,'RTK FHD HDR (NVIDIA High Definition Audio)')
        target_device_idxs=[target_device_idxs,i]; %#ok<AGROW>
    end      
    if contains(current_deviceName,'UltraMic')
        recording_device = i-1;
    end
end
PPA.devicetouse_M1=target_device_idxs(1)-1;
PPA.devicetouse_M2=target_device_idxs(2)-1;
PPA.handle_M1 = PsychPortAudio('Open', PPA.devicetouse_M1, 1, 1, PPA.freq, PPA.nrchannels);
PPA.handle_M2 = PsychPortAudio('Open', PPA.devicetouse_M2, 1, 1, PPA.freq, PPA.nrchannels);

PPA.PunishSound = ((rand(1,PPA.freq *.5)*2) - 1);
% Generate early withdrawal sound
W1 = GenerateSineWave(PPA.freq, 1000, .5); W2 = GenerateSineWave(PPA.freq, 1200, .5); EarlyWithdrawalSound = W1+W2;
P =PPA.freq/100; Interval = P;
for x = 1:50 % Gate waveform to create pulses
    EarlyWithdrawalSound(P:P+Interval) = 0;
    P = P+(Interval*2);
end
PPA.EarlyWithdrawalSound = EarlyWithdrawalSound;
PPA.StartSound = GenerateSineWave(PPA.freq, 10000, .3);
[PPA.RewardSound, ~] = audioread('Clicking-sound-effect.mp3');
PPA.RewardSound = PPA.RewardSound';
PPA.RewardSound = mean(PPA.RewardSound,1);
PPA.Volume = 1;
end