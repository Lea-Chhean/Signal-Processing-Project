function [x, Fs] = preprocess_audio(filename, Fs)
% STEP 1 - Pre-processing: load an audio file, downmix it to mono
% and resample it to Fs (8 kHz by default).
%
% Input : filename = audio file name 
%         Fs       = target sampling frequency in Hz (default 8000)
% Output: x  = mono signal (column vector)
%         Fs = sampling frequency (Hz)

if nargin < 2, Fs = 8000; end

[x, Fs0] = audioread(filename);          % x: samples x (1 or 2 channels)
if size(x,2) > 1
    x = mean(x, 2);                      % stereo -> mono (average L/R)
end

% resample = anti-aliasing low-pass filter + decimation
x = resample(x, Fs, Fs0);
end
