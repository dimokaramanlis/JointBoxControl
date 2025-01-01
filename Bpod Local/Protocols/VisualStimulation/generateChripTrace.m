function [chrptrace,chrptimes] = generateChripTrace(stimPara, fps)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


pdurs = round(stimPara.partdurations * fps);
cumpdurs = [0; cumsum(pdurs)];
Ntot  = sum(pdurs);
chrptrace = zeros(1, Ntot);
chrptimes = ((0:Ntot-1) + 0.5)/fps;
%==========================================================================
% generate steps
chrptrace(cumpdurs(2)+1:cumpdurs(3)) = 1;
chrptrace(cumpdurs(4)+1:cumpdurs(5)) = 0.5;
chrptrace(cumpdurs(6)+1:cumpdurs(7)) = 0.5;
chrptrace(cumpdurs(8)+1:cumpdurs(9)) = 0.5;
%==========================================================================
% generate freq sweep
idsfreq  = cumpdurs(5)+1:cumpdurs(6);
tfreq    = chrptimes(idsfreq);
tfreq    = tfreq - tfreq(1);
minfreq  = stimPara.freqsweep.lo_freq;
maxfreq  = stimPara.freqsweep.hi_freq;
freqvec  = linspace(minfreq, maxfreq, numel(idsfreq));
freqstim = (sin(2 * pi * freqvec .* (tfreq/2)) + 1)/2;
chrptrace(idsfreq) = freqstim;
%==========================================================================
% generate contrast sweep
idscon   = cumpdurs(7)+1:cumpdurs(8);
tcon     = chrptimes(idscon);
tcon     = tcon - tcon(1);
confreq  = stimPara.ctrsweep.freq;
convec   = linspace(0, stimPara.ctrsweep.contrast, numel(idscon));
constim  = (convec .* sin(2 * pi * confreq .* tcon) + 1)/2;
chrptrace(idscon) = constim;
%==========================================================================

end

