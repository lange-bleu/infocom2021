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

mixed_audio_path='eva-focus/mixed.wav';
% mixed_audio_path='utils/google.mp3';
port=1;
ampExcite = 2; % Vpp
% for AM modulation
m = 0.5;

f_end = 32e3; % sweep frequency Hz
delta_f = 1e2;
f_start = 26e3;
% fvect = [f_start:delta_f:f_end];
fvect = [25.3].*1e3;

%

%% play mixed_audio
[y, Fs] = audioread(mixed_audio_path);
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

lengthpuresignal = length(mask_audio);
lengthzeros = 1e4;
% r = lengthzeros/2/lengthpuresignal; % r for generate tukey window
r=0.3;
mask_audio = [zeros(lengthzeros,1);mask_audio;zeros(lengthzeros,1)];


sRate = aFs*Fs;

%% parameters of 33500 waveform generator
Address_33500 = '10';
sRate_33500 = sRate;
numFreqs = length(fvect);
burstPeriod = 8; % s
pausePeriod = 16; % s


%% interpolation
x = (1:length(mask_audio))';
xi = (1/aFs:1/aFs:length(mask_audio))';

yi = interp1q(x,mask_audio,xi)';
yi(isnan(yi))=0;
yi = yi/abs(max(yi));

lengthArb = length(yi);
t = (1:lengthArb)/sRate_33500;

%% Link
% Clear MATLAB workspace of any previous instrument connections
instrreset;
fgen = LinkTo33500_GPIB(Address_33500,lengthArb);

name = 'maskUltra1';
%% Sweeping Measurement
if flagNewTest~=0
    % create waitbar for sweeping
    hwait = waitbar(0,' Please wait >>>>>>>>');
    for ifc = 1:length(fvect)
        fc = fvect(ifc);
        
        % exciting
        %     t = (1:length(yi))/(sRate);
        Mod1 = m*yi.*cos(2*pi*fc*t);
        winTukey = tukeywin(length(yi),r);
        Mod2 = Mod1 + winTukey'.*cos(2*pi*fc*t);
        %         if numFreqs <=10
        %         else
        %             msgbox('Too many fc is employed','Error Message','error')
        %             break
        %         end
        %         waveSendErrorBit = arbitraryTo33500_WaveformSend(Mod2,fgen,name);
        waveSendErrorBit = port_arbitraryTo33500_WaveformSend(Mod2,fgen,name,port);
        if ~waveSendErrorBit % if exciting works
            pause(0.01);
        else % if exciting error
            msgbox('Error occurred trying to sending waveform','Error Message','error')
            break
        end
        %         %update waitbar
        %         figure(hwait)
        %         PerStr = fix(ii/numFreqs*1e4)/1e2;
        %         str=['Send Waveforms Processing ',num2str(PerStr),'%'];
        %         waitbar(ii/numFreqs,hwait,str);
        %         pause(0.01);
        %         ii = ii+1;
        %     end
        %     figure(hwait)
        %     delete(hwait);
        % end
        % hwait = waitbar(0,' Please wait >>>>>>>>');
        % ii = 1;
        %
        %        %update waitbar
        figure(hwait)
        PerStr = fix(ifc/numFreqs*1e4)/1e2;
        str=['fc=' num2str(fc/1e3) '  Processing ',num2str(PerStr),'%'];
        waitbar(ifc/numFreqs,hwait,str);
        pause(0.01);
        % for fc = f_start:delta_f:f_end
        %     name = [namepre num2str(ii)];
        %         exciteErrorBit = arbitraryTo33500_Burst(fgen,ampExcite,sRate_33500,name,burstPeriod);
        exciteErrorBit = port_arbitraryTo33500_Burst(fgen,ampExcite,sRate_33500,name,burstPeriod,port);
        if ~exciteErrorBit % if exciting works
            pause(pausePeriod);
        else % if exciting error
            msgbox('Error occurred trying to exciting signal','Error Message','error')
            break
        end
        fprintf(fgen,['OUTPUT' int2str(port) ' OFF']); %Enable Output for channel 1
        %     pause(burstPeriod);
        
        ifc = ifc+1;
        
    end
    %get rid of message box
%     figure(hwait)
%     delete(hwait);
end
%% Close instrument connection
% fprintf(fgen,'OUTPUT1 OFF'); %Enable Output for channel 1
fclose(fgen);
toc
figure;
