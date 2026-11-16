function [SdB, t, f] = compute_spectrogram(x, Fs, N)
% STEP 2 - Spectrogram in dB (STFT with a Hann window).
%
% Input : x  = mono signal
%         Fs = sampling frequency (Hz)
%         N  = window length in samples (default 1024)
% Output: SdB = K x M matrix (rows = frequency bins, columns = time frames)
%         t   = time of each column (s)
%         f   = frequency of each row (Hz)

if nargin < 3, N = 1024; end
H = N/2;                                 % hop size (50 % overlap)
w = hann(N, 'periodic');                 % Hann window

% spectrogram(x, window, overlap, Nfft, Fs)
[X, f, t] = spectrogram(x, w, N-H, N, Fs);

S   = abs(X).^2;                         % energy (magnitude only, phase discarded)
SdB = 10*log10(S + eps);                 % in decibels (eps avoids log(0))
end
