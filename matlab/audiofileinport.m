% mobile test results processing
clc
clear
% close all
[fileName, pathName] = uigetfile({'*.m4a';'*.mp3';'*.wav';'*.flac';'*.*'},...
                          'AudioFile Selector');
filepath = fullfile(pathName,fileName);
[y,Fs] = audioread(filepath);
lengthy = length(y);
t = (1:lengthy)./Fs;
figure;
plot(t,y)
xlabel('Time (s)')
ylabel('Amplitude')

tLow = 286;
tHigh = tLow + 40;
[~,iLow] = min(abs(tLow-t));
[~,iHigh] = min(abs(tHigh-t));
signal = y(iLow:iHigh,1);

figure;
subplot(3,1,1)
plot((1:length(signal))./Fs,signal);
subplot(3,1,2:3)
% spectrogram(signal,hamming(2048),2000,2048,Fs,'yaxis');
spectrogram(signal,hamming(512),500,512,Fs,'yaxis');