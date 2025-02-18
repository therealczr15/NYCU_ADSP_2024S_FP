%%%% Quiz 1 (ADSP 2024)
%%%% We will make an image from the raw 96-channel data collected by a 96-element phased array. The beamforming technique used here is synthetic aperture.  
%%%% You need to complete the beamforming and envelope detection to obtain the final B-mode image.
%%%% Created by Geng-Shi Jeng 5/21/2024

close all
clear all

load PA_chdata      %% Load the channel data and the associated parameters. 
%==============================

%data;  %Ultrasound full dataset collected by each Tx and Rx combination.
       %4096 x 96 x 96 matrix size. 4096 means number of the range samples. The first 96 means the received channel index whereas the 2nd 96 means the transmitted channel index.
[Nz, Nx, Nt] = size (data);  % Nz=4096 (Samples), Nx = 96 (Rx), Nt = 96 (Tx)

fc = B_fo;               %  center frequency [Hz]
c = SV;                  %  Speed of sound [m/s]
fs;                      % sampling rate or frequency  (Hz)
toff = B_Toffset;        % the starting time for channel data  (s)

%%%% Array coordinate
chx =-1*(Nx-1)/2*pitch:pitch:(Nx-1)/2*pitch; % x-coordinate of a phased array. The element spacing (i.e., pitch) is the variable called "pitch". The number of elements is Nx (or Nt)  (m)
chz = zeros(1,Nx);   %z-coordinate of a phased array (m)

%%%% Paramters for Field of View (FOV) and scan lines
FOV_angle = 90*pi/180; % The angle of FOV (in radian).  
d_th = sin(0.9/1.5/180*pi);  % the angle increment between the successive scan lines.
no_lines = round(2*sin(FOV_angle/2)/d_th);  % determining the number of scan lines
if mod(no_lines,2) == 0  % Forcing no_lines to be odd.
   no_lines = no_lines+1;             
end

%%% Depth information for B-mode
dz = 1/(4*fc)*c/2;        % range sampling interval (m)
range = 0:dz:80*10^(-3);  % The sampling range points for beamforming  (m)
Nr = max(size(range));  % number of the sampling range points

% ======================== Synthetic aperture beamforming =============================
% interpolation on acquired channel data
interp_num = 1;     %%%-------------------> You can play with this value to see if the imaging quality varies.

%%% high-pass filter to remove the unwanted signals of the channel data around DC.  
hpf = fir1(32,0.2,'high');

%%%% Synthetic aperture beamforming
bf = zeros(Nr,no_lines); % initialization of final beamformation result 

gaps = 6;

tic

for ii= [1:gaps:13, 20:gaps+1:48, 49:gaps+1:77, 84:gaps:96]  % for every ii transmit element
ii
    %%% Read the raw data for each ii transmit element
    bb_data1 = data(:,:,ii);   
    [Nz, Nx] = size(bb_data1);

    bb_data = conv2(hpf.',1,bb_data1,'same');  % high-pass filter to remove the unwanted signals of the channel data around DC.  
    bb_data = resample(bb_data,interp_num,1);  %interpolation of the channel data in the range direction by a factor of interp_num
    
    %%% Initialization for each sub-image associated with ii-th Tx emission.
    subbf = zeros(Nr, no_lines);

    for jj = 1: no_lines  %% for each scan line
        
        % The scan line position
         sin_th = -1*(no_lines-1)/2*d_th  + (jj-1)*d_th;
         cos_th = cos(asin(sin_th));

         %%%% Delay and Sum (DAS) to realize the beamforming
         % Rx distance  (You should calculate the distance between each image pixel to ALL receive channels)
         Rx_dist = zeros(Nr,Nx);           % initialization of the Rx distance
         % Rx_dist =                                                ----------------------------------------------->   You  need complete the code here 
         chx_rx = repmat(chx,Nr,1);
         Rx_dist = sqrt((chx_rx - range.'*sin_th).^2 + (range.'*cos_th).^2);  % Calculate Rx distance
         
         % Tx distance (You should calculate the distance between each image pixel to ii-th transmit channel)
         Tx_dist = zeros(Nr,Nx);           % initialization of the Tx distance
         % Tx_dist =                                                ----------------------------------------------->   You  need complete the code here 
         chx_tx = repmat(chx(:,ii),Nr,Nx);
         Tx_dist = sqrt((chx_tx - range.'*sin_th).^2 + (range.'*cos_th).^2);  % Calculate Tx distance
         
         % Calculate the total delay for ii-th Tx channel to ALL Rx channels.
         totdelay = (Rx_dist + Tx_dist)/c-toff;  % total delay 
         delayindx = round(totdelay*fs*interp_num)+1;  % convert the total delay to the sample index.
          
         %%% Find the sample according to "delayindx" and do the summation 
         % subbf(:,jj) =   % sub-image for ii-th Tx emission       ----------------------------------------------->   You  need complete the code here 
         for kk = 1 : Nx
             for mm = 1 : Nr
                if delayindx(mm,kk) > 0 && delayindx(mm,kk) <= size(bb_data,1)
                    subbf(mm,jj) = subbf(mm,jj) + bb_data(delayindx(mm,kk),kk); 
                end
             end
         end
    end
    bf = bf + subbf;   % summation among all sub-images.
    
end

%%% Envelope detection 
bf_env = zeros(Nr,no_lines); % initialization of envelope detected result
%bf_env =                    % envelope detected result               ----------------------------------------------->   You  need complete the code here 
bf_env = abs(hilbert(bf));  % with doing envelope detection

%%% Log compression
bf_env_nor = abs(bf_env)/max(max(abs(bf_env)));  % normalized to 1.
srcInt = 20*log10(bf_env_nor);

toc

%%% Display the result
DR=60;   % dynamic range

%%% scan conversion (From rectangle to polar format)
sin_th = -1*(no_lines-1)/2*d_th + ([1:1:no_lines]-1)*d_th; 
cos_th = cos(asin(sin_th));
Z=range.'*cos_th;
X=range.'*sin_th;

figure
pcolor(X*1e3, Z*1e3, srcInt+DR )
axis('ij');
shading interp;
caxis([0 DR])
colorbar
colormap gray
xlabel('Lateral distance [mm]')
ylabel('Axial distance [mm]')
title('Phased array imaging - with envelope detection (emissions reduced)')
axis equal

%%% save emission reduction result
save("emi_redu_img.mat", "bf_env_nor")

ori_img = importdata("ori_img.mat");
emi_redu_img = importdata("emi_redu_img.mat");

similarity = ssim(ori_img, emi_redu_img);

fprintf("Similarity: %.5f \n", similarity)
