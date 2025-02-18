%% Quiz 2: Time-Frequency Analysis of Music. One is the original music and the other one is the sound recorded by parametric speaker (Google it!)
clear all 

%%% Read out two music (fs is the sampling frequency)
[org_music fs] = audioread('org.mp4'); %original music
[par_music fs] = audioread('par.mp4'); % parametric sound

N1 = length(org_music);  % length of the data
N2 = length(par_music);  %  N1 is the same as N2
t_indx = [0:1:N1-1]*1/fs;  % time index in second

%%% Question 2.2
%%% Time-frequency analysis (Complete all codes and display the STFT results)  
%%% Note1: You can use MATLAB "stft" function or write
%%% STFT by yourself, but you need to specific the following four
%%% parameters: Window size, Windowing function, FFT length, Overlapping
%%% length.
       
%%% Note2: Because the analysis is time comsuming, you can crop your data
%%% to be a length of 220000 (roughly 5 seconds).

%%% Note3: Display your STFT result in dB within the frequency range of 0-4000 Hz. 

% STFT parameters
w_len = 4096;  % window size for STFT
win = hamming(w_len);  % Windowing function  
fft_len = 8192;  % FFT length for STFT (can be different from the window size).
OverlapLength = w_len / 2;  % Overlapping window length between two STFT analses.  

% Crop data to roughly 5 seconds
crop_length = 220000;
org_music_cropped = org_music(1:crop_length);
par_music_cropped = par_music(1:crop_length);

% Perform STFT
[s_org, f_org, t_org] = stft(org_music_cropped, fs, 'Window', win, 'OverlapLength', OverlapLength, 'FFTLength', fft_len);
[s_par, f_par, t_par] = stft(par_music_cropped, fs, 'Window', win, 'OverlapLength', OverlapLength, 'FFTLength', fft_len);

% Convert to dB
s_org_db = mag2db(abs(s_org));
s_par_db = mag2db(abs(s_par));

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
imagesc(t_par, f_par, s_par_db);
cb = colorbar();
caxis([-20, 50]);
colormap jet;
axis xy;
ylim([0 4000]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
ylabel(cb, 'Magnitude (dB)');
title('STFT of Parametric Sound');
