microphone_scratch;
plot(recordedaudio)
ss = spectrogram(recordedaudio,128,120,128,fscapture,'yaxis');
plot(ss(5:6,:))
plot(abs(ss(5:6,:)))
oplot = ss(5:6,1:fscapture*5);
plot(abs(toplot))
plot(abs(oplot))
toplot = ss(5:6,1:fscapture*5);
plot(abs(toplot))
plot(abs(toplot)')
plot(abs(ss(5:6,:))')
close all
plot(abs(ss(5:6,:))')
load('D:\audio_testing\8k_max_audio_001to016_joint_setup.mat')
ss = spectrogram(recordedaudio,128,120,128,fscapture,'yaxis');
figure
plot(abs(ss(5:6,:))')
title('Joint Setup')
figure
plot(recordedaudio)
title('Joint Setup')
load('D:\audio_testing\8k_max_audio_001to016_box.mat')
figure
plot(recordedaudio)
title('Box')
figure
ss = spectrogram(recordedaudio,128,120,128,fscapture,'yaxis');