function PlayStartTone()
%PLAYSTARTTONE Summary of this function goes here
%   Detailed explanation goes here
    global PPA S 
        PsychPortAudio('Stop', PPA.handle_M1);
        PsychPortAudio('Stop', PPA.handle_M2);
        PsychPortAudio('Volume', PPA.handle_M1, S.GUI.SoundVolume);
        PsychPortAudio('Volume', PPA.handle_M2, S.GUI.SoundVolume);
        disp(S.GUI.SoundVolume);
        PsychPortAudio('FillBuffer', PPA.handle_M1,...
                        [PPA.RewardSound;...
                        PPA.RewardSound;]);
        PsychPortAudio('FillBuffer', PPA.handle_M2,...
                        [PPA.RewardSound;...
                         PPA.RewardSound;]);
        PsychPortAudio('Start', PPA.handle_M1, PPA.repetitions, PPA.starttime, PPA.waitForDeviceStart);
        PsychPortAudio('Start', PPA.handle_M2, PPA.repetitions, PPA.starttime, PPA.waitForDeviceStart);
        disp('Played Start Tone');

%         if S.GUI.PunishSound
%             PsychPortAudio('Stop', PPA.handle_M1);
%             PsychPortAudio('Stop', PPA.handle_M2);
%             PsychPortAudio('FillBuffer', PPA.handle_M1,...
%                             [PPA.PunishSound;...
%                             zeros(size(PPA.PunishSound));]);
%             PsychPortAudio('FillBuffer', PPA.handle_M2,...
%                             [PPA.PunishSound;...
%                             zeros(size(PPA.PunishSound));]);
%             PsychPortAudio('Start', PPA.handle_M1, PPA.repetitions, PPA.starttime, PPA.waitForDeviceStart);
%             PsychPortAudio('Start', PPA.handle_M2, PPA.repetitions, PPA.starttime, PPA.waitForDeviceStart);
%         end
end