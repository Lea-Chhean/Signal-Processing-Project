% TEST of steps 1 to 3 on one track to check the constellation visually.
clear; clc; close all;

file = '002099.mp3';          % The name of one of the track to test
N  = 1024;                    % window length
Fs = 8000;                    % sampling frequency after resampling

[x, Fs]     = preprocess_audio(file, Fs);
[SdB, t, f] = compute_spectrogram(x, Fs, N);
[m, k]      = pick_peaks(SdB, f, 5, 5, 15);

% Peak density (target: roughly 25 to 35 peaks/s)
duration = numel(x)/Fs;
fprintf('Duration: %.1f s | peaks: %d | density rho = %.1f peaks/s\n', ...
        duration, numel(m), numel(m)/duration);

% Spectrogram with the constellation on top
figure;
imagesc(t, f, SdB); axis xy; colormap(gray); hold on;
plot(t(m), f(k), 'r.', 'MarkerSize', 8);
xlabel('Time (s)'); ylabel('Frequency (Hz)');
title('Spectrogram (dB) + constellation map');

% Test: constellation of an excerpt vs the original, shifted in time
m0 = 80;                                   % shift in frames (multiple of H = 512 samples)
xq = x(m0*512 + 1 : m0*512 + 8*Fs);        % 8 s excerpt
[SdBq, ~, fq] = compute_spectrogram(xq, Fs, N);
[mq, kq] = pick_peaks(SdBq, fq, 5, 5, 15);  % same settings as above

common = ismember([mq + m0, kq], [m, k], 'rows');
fprintf('Excerpt peaks found in the original: %.0f %%\n', 100*mean(common));
