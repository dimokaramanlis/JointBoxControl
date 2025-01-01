currenthostname = getenv('COMPUTERNAME');

InitializePsychSound(1);

devices = PsychPortAudio('GetDevices');

% find ultramic
devfind1  = contains({devices(:).DeviceName}, 'UltraMic');
devfind2  = contains({devices(:).HostAudioAPIName}, 'WASAPI');
devidx    = find(devfind1 & devfind2);
fscapture = devices(devidx).DefaultSampleRate;

pahandle = PsychPortAudio('Open', devidx-1, 2, 1, [], 1);
maxsecs = 150;
% Get what freq'uency we are actually using:
s = PsychPortAudio('GetStatus', pahandle);
freq = s.SampleRate;

% Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
PsychPortAudio('GetAudioData', pahandle, 10);

% Start audio capture immediately and wait for the capture to start.
% We set the number of 'repetitions' to zero,
% i.e. record until recording is manually stopped.
PsychPortAudio('Start', pahandle, 0, 0, 1);

fprintf('Audio capture started, press any key for about 1 second to quit.\n');
% We retrieve status once to get access to SampleRate:
s = PsychPortAudio('GetStatus', pahandle);
recordedaudio = [];
% Stay in a little loop until keypress:
while ~KbCheck &&  ((length(recordedaudio) / s.SampleRate) < maxsecs)
    % Wait a second...
    WaitSecs(1);

    % Query current capture status and print it to the Matlab window:
    s = PsychPortAudio('GetStatus', pahandle);

    % Print it:
    fprintf('\n\nAudio capture started, press any key for about 1 second to quit.\n');
    fprintf('This is some status output of PsychPortAudio:\n');
    disp(s);

    % Retrieve pending audio data from the drivers internal ringbuffer:
    audiodata = PsychPortAudio('GetAudioData', pahandle);
    nrsamples = size(audiodata, 2);

%     % Plot it, just for the fun of it:
    plot(1:nrsamples, audiodata(1,:), 'k');
    drawnow;

    % And attach it to our full sound vector:
    recordedaudio = [recordedaudio audiodata]; %#ok<AGROW>
end

% Stop capture:
PsychPortAudio('Stop', pahandle);

% Perform a last fetch operation to get all remaining data from the capture engine:
audiodata = PsychPortAudio('GetAudioData', pahandle);

% Attach it to our full sound vector:
recordedaudio = [recordedaudio audiodata];

% Close the audio device:
PsychPortAudio('Close', pahandle);

RestrictKeysForKbCheck([]);



