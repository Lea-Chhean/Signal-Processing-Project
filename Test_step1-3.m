% TEST of steps 1 to 3 on SEVERAL tracks
clear; clc; close all;

folder = 'sons_test_step1-3';
files  = {'002099.mp3', '002096.mp3', '005002.mp3'};
N  = 1024;
Fs = 8000;
dk = 5; dm = 3; margin = 10;

nF = numel(files);
M = cell(nF,1); K = cell(nF,1);

% 1) Constellation of each track + display
figure;
for i = 1:nF
    [x, Fs]     = preprocess_audio(fullfile(folder, files{i}), Fs);
    [SdB, t, f] = compute_spectrogram(x, Fs, N);
    [m, k]      = pick_peaks(SdB, f, dk, dm, margin);
    M{i} = m; K{i} = k;

    duration = numel(x)/Fs;
    fprintf('%s | %.1f s | peaks: %d | rho = %.1f peaks/s\n', ...
        files{i}, duration, numel(m), numel(m)/duration);

    subplot(nF, 1, i);
    imagesc(t, f, SdB); axis xy; colormap(gray); hold on;
    plot(t(m), f(k), 'r.', 'MarkerSize', 8);
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    title(files{i}, 'Interpreter', 'none');
end

% 2) Excerpt of one track compared against all tracks
q  = 2;
m0 = 80;
H  = N/2;

[x, ~] = preprocess_audio(fullfile(folder, files{q}), Fs);
xq = x(m0*H + 1 : m0*H + 8*Fs);
[SdBq, ~, fq] = compute_spectrogram(xq, Fs, N);
[mq, kq]      = pick_peaks(SdBq, fq, dk, dm, margin);

score = zeros(nF,1);
for i = 1:nF
    score(i) = mean(ismember([mq + m0, kq], [M{i}, K{i}], 'rows'));
    fprintf('%s : %.0f %%\n', files{i}, 100*score(i));
end
[~, best] = max(score);
fprintf('Identified track: %s (expected: %s)\n', files{best}, files{q});
