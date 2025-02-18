%% Quiz 2: Time-Frequency Analysis of Music. One is the original music and the other one is the sound recorded by parametric speaker (Google it!)
clear all 

%%% Read out two music (fs is the sampling frequency)
[org_music fs] = audioread('org.mp4'); %original music
[par_music fs] = audioread('par.mp4'); % parametric sound

N1 = length(org_music);  % length of the data
N2 = length(par_music);  %  N1 is the same as N2
t_indx = [0:1:N1-1]*1/fs;  % time index in second

%%% Question 2.3.  Improve the parametric sound by filtering. Complete your
%%% design below, and output the sound as a mp4 file using the following
%%% function.

% Design a high-pass filter to filter noise in 100Hz
hpf = fir1(32, 100 / (fs / 2), 'high');
par_music_fn = filtfilt(hpf, 1, par_music);

% Design a band-pass filter for 100 Hz to 500 Hz and amplify the signal 8 times
d1 = designfilt('bandpassiir', 'FilterOrder', 4, ...
    'HalfPowerFrequency1', 100, 'HalfPowerFrequency2', 500, ...
    'SampleRate', fs);

low_freq_component = filtfilt(d1, par_music_fn);
low_freq_component_amplified = low_freq_component * 8;  % Amplify the low frequency component

% Design a band-pass filter for 500 Hz to 1000 Hz and amplify the signal double
d2 = designfilt('bandpassiir', 'FilterOrder', 4, ...
    'HalfPowerFrequency1', 500, 'HalfPowerFrequency2', 1000, ...
    'SampleRate', fs);

mid_freq_component = filtfilt(d2, par_music_fn);
mid_freq_component_amplified = mid_freq_component * 2;  % Amplify the low frequency component

% Design a band-pass filter for 1k Hz to 15 kHz and reduce the signal amplitude to 0.9
d3 = designfilt('bandpassiir', 'FilterOrder', 4, ...
    'HalfPowerFrequency1', 1000, 'HalfPowerFrequency2', 15000, ...
    'SampleRate', fs);

high_freq_component = filtfilt(d3, par_music_fn);
high_freq_component_reduced = high_freq_component * 0.9;  % Reduce the high frequency component

% Combine the two components
par_music_improved = low_freq_component_amplified + mid_freq_component_amplified + high_freq_component_reduced;

% Output the improved sound as a mp4 file
audiowrite('par_improvement.mp4', par_music_improved, fs);

% STFT parameters
w_len = 4096;  % window size for STFT
win = hamming(w_len);  % Windowing function  
fft_len = 8192;  % FFT length for STFT (can be different from the window size).
OverlapLength = w_len / 2;  % Overlapping window length between two STFT analses.  

% Crop data to roughly 10 seconds
crop_length = 440000;
org_music_cropped = org_music(1:crop_length);
par_music_imp_cropped = par_music_improved(1:crop_length);

% Perform STFT
[s_org, f_org, t_org] = stft(org_music_cropped, fs, 'Window', win, 'OverlapLength', OverlapLength, 'FFTLength', fft_len);
[s_par_imp, f_par_imp, t_par_imp] = stft(par_music_imp_cropped, fs, 'Window', win, 'OverlapLength', OverlapLength, 'FFTLength', fft_len);

% Convert to dB
s_org_db = mag2db(abs(s_org));
s_par_imp_db = mag2db(abs(s_par_imp));

% Display STFT results
figure
imagesc(t_org, f_org, s_org_db);
cb = colorbar();
caxis([-20, 50]);
colormap jet;
axis xy;
ylim([0 4000]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
ylabel(cb, 'Magnitude (dB)');
title('STFT of Original Music');

figure
imagesc(t_par_imp, f_par_imp, s_par_imp_db);
cb = colorbar();
caxis([-20, 50]);
colormap jet;
axis xy;
ylim([0 4000]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
ylabel(cb, 'Magnitude (dB)');
title('STFT of Improved Parametric Sound');