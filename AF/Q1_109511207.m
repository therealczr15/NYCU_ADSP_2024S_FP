% Load the signals
load('x_plus_v1.mat');
load('v2.mat');

% Parameters
mu = 0.01; % Step size
M = 147; % Filter order (equivalent to 10 ms at 14.7 kHz)
N = length(x_plus_v1); % Number of samples

% Initialize variables
w = zeros(M, 1); % Filter coefficients
y = zeros(N, 1); % Filter output
e = zeros(N, 1); % Error signal

% LMS Algorithm
tic
for n = M:N
    x = v2(n:-1:n-M+1); % Input vector
    y(n) = w' * x; % Filter output
    e(n) = x_plus_v1(n) - y(n); % Error signal
    w = w + mu * e(n) * x; % Update filter coefficients
end
toc

% Plot Weight
figure;
plot(w);
title('Weight');

% Play the filtered signal
sound(e, 14700);

% Plot the results
figure;
subplot(3,1,1);
plot(x_plus_v1);
title('Original Signal (x(n) + v_1(n))');
subplot(3,1,2);
plot(v2);
title('Noise Signal (v_2(n))');
subplot(3,1,3);
plot(e);
title('Filtered Signal (e(n))');

% STFT parameters
w_len = 4096;  % window size for STFT
win = hamming(w_len);  % Windowing function  
fft_len = 8192;  % FFT length for STFT (can be different from the window size).
OverlapLength = w_len / 2;  % Overlapping window length between two STFT analses.  

% Perform STFT
[s_x_plus_v1, f_x_plus_v1, t_x_plus_v1] = stft(x_plus_v1, 14700, 'Window', win, 'OverlapLength', OverlapLength, 'FFTLength', fft_len);
[s_e, f_e, t_e] = stft(e, 14700, 'Window', win, 'OverlapLength', OverlapLength, 'FFTLength', fft_len);

% Convert to dB
s_x_plus_v1_db = mag2db(abs(s_x_plus_v1));
s_e_db = mag2db(abs(s_e));

% Display STFT results
figure
imagesc(t_x_plus_v1, f_x_plus_v1, s_x_plus_v1_db);
cb = colorbar();
caxis([-20, 50]);
colormap jet;
axis xy;
ylim([0 4000]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
ylabel(cb, 'Magnitude (dB)');
title('STFT of Original Signal');

figure
imagesc(t_e, f_e, s_e_db);
cb = colorbar();
caxis([-20, 50]);
colormap jet;
axis xy;
ylim([0 4000]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
ylabel(cb, 'Magnitude (dB)');
title('STFT of Filtered Signal');

