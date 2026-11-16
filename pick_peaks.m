function [m, k] = pick_peaks(SdB, f, dk, dm, margin)
% STEP 3 - Constellation map: keep only the local energy maxima.
%
% Input : SdB    = spectrogram in dB (K x M)
%         f      = frequency of each row (Hz)
%         dk, dm = neighbourhood half-sizes (bins, frames)       [5, 3]
%         margin = margin above the band median, in dB           [10]
% Output: m, k   = frame and bin indices of the peaks, sorted by increasing time

if nargin < 3, dk = 5;      end
if nargin < 4, dm = 3;      end
if nargin < 5, margin = 10; end

% 1) Sliding maximum over a (2dk+1) x (2dm+1) rectangle
%    (two 1-D passes give the same result as a 2-D rectangle, no toolbox needed)
Smax  = movmax(movmax(SdB, 2*dk+1, 1), 2*dm+1, 2);
isMax = (SdB == Smax);                   % "strongest in its neighbourhood"

% 2) LOCAL threshold per band (6 log-spaced bands between 200 and 4000 Hz)
fmin = 200; fmax = 4000; Nb = 6;
edges  = fmin * (fmax/fmin).^((0:Nb)/Nb);   % 200 330 543 894 1474 2428 4000
isPeak = false(size(SdB));
for b = 1:Nb
    rows = find(f >= edges(b) & f < edges(b+1));
    tau  = median(SdB(rows,:), 'all') + margin;      % threshold for this band
    isPeak(rows,:) = isMax(rows,:) & (SdB(rows,:) >= tau);
end

% 3) Peak coordinates (we keep (m,k) only, NEVER the amplitudes)
[k, m] = find(isPeak);
[m, ord] = sort(m);  k = k(ord);
end
