%% Quiz 2: Time-Frequency Analysis of Music. One is the original music and the other one is the sound recorded by parametric speaker (Google it!)
clear all 

%%% Read out two music (fs is the sampling frequency)
[org_music fs] = audioread('org.mp4'); %original music
[par_music fs] = audioread('par.mp4'); % parametric sound

N1 = length(org_music);  % length of the data
N2 = length(par_music);  %  N1 is the same as N2
t_indx = [0:1:N1-1]*1/fs;  % time index in second

%%% Question 2.1: Display waveform and spectrum
figure
plot(t_indx, org_music)
hold on
plot(t_indx, par_music)
xlabel('Time (s)')
ylabel('Magnitude')
title('Time-domain waveform comparison')
legend('Original music','Parametric sound')

%%% FFT of both music 
f_org = fft(org_music);
f_par = fft(par_music);

figure
plot(([0:1:N1-1]/N1-0.5)*fs,20*log10(abs(fftshift(f_org))))
hold on
plot(([0:1:N1-1]/N1-0.5)*fs,20*log10(abs(fftshift(f_par))))
xlim([0 2000])  % confine the display frequency range
ylim([-20 80])  % confine the display magnitude
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
title('Spectrum comparision')
legend('Original music','Parametric sound')
