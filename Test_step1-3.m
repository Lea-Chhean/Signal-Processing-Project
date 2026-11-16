% TEST of steps 1 to 3 on SEVERAL tracks
clear; clc; close all;

files = {'002099.mp3', '002096.mp3', '005002.mp3'};   %the FMA tracks
N  = 1024;                    % window length
Fs = 8000;                    % sampling frequency after resampling
dk = 5; dm = 5; margin = 15;  % pick_peaks parameters

nF = numel(files);
M = cell(nF,1);  K = cell(nF,1);        % constellation of each track

% 1) Constellation of each track + display
figure;
for i = 1:nF
    [x, Fs]     = preprocess_audio(files{i}, Fs);
    [SdB, t, f] = compute_spectrogram(x, Fs, N);
    [m, k]      = pick_peaks(SdB, f, dk, dm, margin);
    M{i} = m;  K{i} = k;

    % Peak density (target: roughly 25 to 35 peaks/s)
    duration = numel(x)/Fs;
    fprintf('%s | %.1f s | peaks: %d | rho = %.1f peaks/s\n', ...
        files{i}, duration, numel(m), numel(m)/duration);

    % Spectrogram with the constellation on top
    subplot(nF, 1, i);
    imagesc(t, f, SdB); axis xy; colormap(gray); hold on;
    plot(t(m), f(k), 'r.', 'MarkerSize', 8);
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    title(files{i}, 'Interpreter', 'none');
end

%2) Excerpt of one track compared against all tracks
q  = 2;                                  % track the excerpt is taken from
m0 = 80;                                 % shift in frames (multiple of H = 512 samples)

[x, ~] = preprocess_audio(files{q}, Fs);
xq = x(m0*512 + 1 : m0*512 + 8*Fs);      % 8 s excerpt
[SdBq, ~, fq] = compute_spectrogram(xq, Fs, N);
[mq, kq] = pick_peaks(SdBq, fq, dk, dm, margin);   % same settings as above

% Fraction of excerpt peaks found in each track's constellation
score = zeros(nF,1);
for i = 1:nF
    score(i) = mean(ismember([mq + m0, kq], [M{i}, K{i}], 'rows'));
    fprintf('%s : %.0f %%\n', files{i}, 100*score(i));
end
[~, best] = max(score);
fprintf('Identified track: %s (expected: %s)\n', files{best}, files{q});
[mq, kq] = pick_peaks(SdBq, fq, 5, 5, 15);  % same settings as above

common = ismember([mq + m0, kq], [m, k], 'rows');
fprintf('Excerpt peaks found in the original: %.0f %%\n', 100*mean(common));
