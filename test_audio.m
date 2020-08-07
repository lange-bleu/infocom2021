clear;
clc;
win_size = 0.01;

[audio, Fs] = audioread('utils/speakerB.wav');
L = length(audio);
win_len = Fs*win_size;
nfft = 1024;
noverlap = win_len/2;

spectrogram(audio, hamming(win_len) ,noverlap, nfft, Fs, 'yaxis' );
set(gca,'FontName','Arial','FontSize',60);
%title('Default spectrogram plot');

% figure;
% Y = fft(audio);
% P2 = abs(Y/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% f = Fs*(0:(L/2))/L;
% plot(f,P1)
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')

%% Carrier Signal
m=0.5;
Am = 1;
fc = 28000;
sRate = 12*Fs;
t = (1:L)/sRate;

re_audio = reshape(audio,1,[]);

% Carrier = cos(2*pi*fc*t);
% Mod1 = (1+m*re_audio).*Carrier;
% Mod2 = Am*Mod1.*Mod1;

Mod1 = m*re_audio.*cos(2*pi*fc*t);
% winTukey = tukeywin(length(re_audio),r);
Mod2 = Mod1 + cos(2*pi*fc*t);

% figure;
% Y1 = fft(Mod2);
% P2 = abs(Y1/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% f = sRate*(0:(L/2))/L;
% plot(f,P1) ;
% title('Single-Sided Amplitude Spectrum of Mod(t)');
% xlabel('f (Hz)');
% ylabel('|P1(f)|');

figure;
win_len = Fs*win_size;
nfft = 1024;
noverlap = win_len/2;

% hop_size = Fs*win_size;
% nfft = hop_size/fft_overlap;
% noverlap = nfft-hop_size;

% w = sqrt(hann(nfft)); %use some window
spectrogram(Mod2, hamming(win_len) ,noverlap, nfft, sRate, 'yaxis' );
set(gca,'FontName','Arial','FontSize',60, 'XTick', 0:83.3:1200);
set(gca, 'XTickLabel', 0:1:6);
xlabel('Time (s)')

%[S, F, T, P] = spectrogram(Mod2, hamming(win_len) ,noverlap, nfft, sRate, 'yaxis' );

% imagesc(gca, F, T, P);

text(20, 70, '2w_c', 'FontSize',60);