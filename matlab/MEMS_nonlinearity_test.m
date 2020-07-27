% Test MEMS micphone's nonliearity with 25.3kHz +- 1kHz
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
%% Initialization
flagNewTest = 1;
aFs = 4;
Fs = aFs*48e3;
namepre = 'MEMStest_';
Ts = 1/Fs;
lengthpuresignal = 1e5;
curfc = 1e3;
tvect = (0:(lengthpuresignal-1)).*Ts;
OKGoogle1 = sin(2*pi*curfc.*tvect);
lengthzeros = 1e4;
% OKGoogle1 = [zeros(1,lengthzeros)]
r = lengthzeros/lengthpuresignal; % r for generate tukey window

sRate = Fs;

% parameters of 33500 waveform generator
Address_33500 = '10';
sRate_33500 = sRate;
ampExcite = 4; % Vpp
f_end = 25.3e3; % sweep frequency Hz
delta_f = 1e2;
f_start = 25.3e3;
numFreqs = (f_end - f_start)/delta_f + 1;
% parameters of Tek MDO3014 oscilloscope
IP_MDO3014 = '169.254.6.185';
sampleRate = 1e6; % Sample Rate
lengthCapture = 1e4; % number of capture points for each frequency
xScale = lengthCapture/sampleRate/10;
yScale = 1;



burstPeriod = 0; % s

%interpolation x5
% x = (1:length(OKGoogle1))';
% xi = (1/Fs:1/aFs:length(OKGoogle1))';
% yi = interp1q(x,OKGoogle1,xi)';
yi = OKGoogle1;
lengthArb = length(yi);
t = (1:lengthArb)/sRate_33500;

% for AM modulation
m = 0.9;



%% Link
% Clear MATLAB workspace of any previous instrument connections
instrreset;
fgen = LinkTo33500_GPIB(Address_33500,lengthArb);
frec = LinkToMDO3014_TCP(IP_MDO3014);

%% Setup fgen & frec
mdo3014setup(frec,xScale,lengthCapture,yScale);

data = zeros(numFreqs,lengthCapture);

%% Sweeping Measurement
if flagNewTest~=0
    % create waitbar for sweeping
    hwait = waitbar(0,' Please wait >>>>>>>>');
    ii = 1;
    for fc = f_start:delta_f:f_end
        Mod1 = m*yi.*cos(2*pi*fc*t);
        winTukey = tukeywin(length(yi),r);
        Mod2 = winTukey'.*(Mod1 + cos(2*pi*fc*t));
        if numFreqs <=10
            name = [namepre num2str(ii)];
        else
            msgbox('Too many fc is employed','Error Message','error')
            break
        end
        waveSendErrorBit = arbitraryTo33500_WaveformSend(Mod2,fgen,name);
        if ~waveSendErrorBit % if exciting works
            pause(0.01);
        else % if exciting error
            msgbox('Error occurred trying to sending waveform','Error Message','error')
            break
        end
        %update waitbar
        figure(hwait)
        PerStr = fix(ii/numFreqs*1e4)/1e2;
        str=['Send Waveforms Processing ',num2str(PerStr),'%'];
        waitbar(ii/numFreqs,hwait,str);
        pause(0.01);
        ii = ii+1;
    end
    figure(hwait)
    delete(hwait);
end
hwait = waitbar(0,' Please wait >>>>>>>>');
ii = 1;


for fc = f_start:delta_f:f_end
    name = [namepre num2str(ii)];
    exciteErrorBit = arbitraryTo33500_Burst(fgen,ampExcite,sRate_33500,name,burstPeriod);
    if ~exciteErrorBit % if exciting works
        pause(0.1);
        % receiving
        captureData = capturedata(frec);
        data(ii,:) = captureData - mean(captureData);
    else % if exciting error
        msgbox('Error occurred trying to exciting signal','Error Message','error')
        break
    end
    fprintf(fgen,'OUTPUT1 OFF'); %Enable Output for channel 1
    pause(burstPeriod);
    %update waitbar
    figure(hwait)
    PerStr = fix(ii/numFreqs*1e4)/1e2;
    str=['Send Waveforms Processing ',num2str(PerStr),'%'];
    waitbar(ii/numFreqs,hwait,str);
    pause(0.01);
    ii = ii+1;
    
end
%get rid of message box
figure(hwait)
delete(hwait);

%% Close instrument connection
% fprintf(fgen,'OUTPUT1 OFF'); %Enable Output for channel 1
fclose(fgen);
fclose(frec);
toc

%% Plot
figure('Name','Spectrums','Color',[1 1 1]);
fvect = linspace(0,sampleRate/2,lengthCapture/2+1);
ff = f_start:delta_f:f_end;
ampVect = zeros(1,numFreqs);
for i = 1:numFreqs
    curFre = curfc;
    curData = data(i,:);
    curFFT = fft(curData);
    P2 = abs(curFFT/lengthCapture);
    P1 = P2(1:lengthCapture/2+1);
    P1(2:end-1) = 2*P1(2:end-1);       
    hold on;    
    plot(fvect/1e3,P1,'Displayname',[num2str(curFre/1e3) 'kHz'])
    [~,iCur] = min(abs(curFre-fvect));
    ampVect(i) = P1(iCur);
end
xlabel('Frequency (kHz)')
ylabel('Amplitude')
xlim([0,f_end/1e3])

figure('Name','Frenquency Respones','Color',[1 1 1])
plot(ff/1e3,ampVect,'Marker','o','LineWidth',2,'Color',[1 0 0])
xlabel('Frequency (kHz)')
