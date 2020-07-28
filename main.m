% Test audio attack huawei voice control system using plate guided
% wave _ Normalmode
% % This program illustrates the use of 33500B waveform and Tektronix
% MSO5000 series oscilloscope to acquire the arbitrary waveform. Agilent VISA will be used for
% communicating with your instrument, please ensure that it is installed.
%
% This script was tested with a Tek MDO3014 and google pixel2
%
% Copyright 2018 Think Lab in UNL.
% by Qi Xia and Kehai Liu, 11/12/2018
clc
clear
close all
tic

mixed_audio_path='utils/speakerA.wav';
% 

%% play mixed_audio
[y, fs] = audioread(mixed_audio_path);
% soundsc(y, fs);
%% add noise
% subplot(2, 1, 1);
% plot(y, 'b-');
% grid on;
% drawnow;
% message = sprintf('Do you want to play the noisy one?');
% reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
% if strcmpi(reply, 'No')
%   % User said No, so exit.
%   return;
% end
% noiseAmplitude = 0.1;
% yNoisy = y + noiseAmplitude * rand(length(y), 1) - noiseAmplitude/2;
% subplot(2, 1, 2);
% plot(y, 'b-');
% grid on;
% drawnow;
% soundsc(yNoisy, fs);

mask_audio=y;

%% pre-processing
flagNewTest = 1;
aFs = 4;
Fs = 48e3;

sRate = aFs*Fs;

% parameters of 33500 waveform generator
Address_33500 = '10';
sRate_33500 = sRate;
ampExcite = 8.5; % Vpp
% f_end = 25.3e3; % sweep frequency Hz
% delta_f = 1e2;
% f_start = 24.7e3;
% numFreqs = (f_end - f_start)/delta_f + 1;
burstPeriod = 5; % s
pausePeriod = 10; % s


%interpolation
x = (1:length(mask_audio))';
xi = (1/aFs:1/aFs:length(mask_audio))';
% yi = OkGoogle1;
% yi = yi/max(abs(yi));
yi = interp1q(x,mask_audio,xi)';
yi = yi/abs(max(yi));
% lengthArb = length(yi);
lengthArb = length(yi);
t = (1:lengthArb)/sRate_33500;

%% Link
% Clear MATLAB workspace of any previous instrument connections
instrreset;
fgen = LinkTo33500_GPIB(Address_33500,lengthArb);

%% Sweeping Measurement
name = 'AOkGoogle';
if flagNewTest~=0
    waveSendErrorBit = arbitraryTo33500_WaveformSend(yi,fgen,name);
    if ~waveSendErrorBit % if exciting works
        pause(0.01);
        exciteErrorBit = arbitraryTo33500_Burst(fgen,ampExcite,sRate_33500,name,burstPeriod);
        if ~exciteErrorBit % if exciting works
            pause(pausePeriod);
        else % if exciting error
            msgbox('Error occurred trying to exciting signal','Error Message','error')
            return
        end
        
    else % if exciting error
        msgbox('Error occurred trying to sending waveform','Error Message','error')
        return
    end
end



%     fprintf(fgen,'OUTPUT1 OFF'); %Enable Output for channel 1
%     pause(burstPeriod);


%% Close instrument connection
% fprintf(fgen,'OUTPUT1 OFF'); %Enable Output for channel 1
fclose(fgen);
toc
