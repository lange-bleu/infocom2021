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

data_root = './group_audio2/';
% data_noise=["joint","babble","volvo"];
data_type = "hide_mixed";



port=1;
ampExcite = 4; % Vpp
% for AM modulation
m = 0.7;

f_end = 32e3; % sweep frequency Hz
delta_f = 1e2;
f_start = 26e3;
% fvect = [f_start:delta_f:f_end];
fvect = [27.2].*1e3;
aFs_shadow = 4;


lengthzeros = 1e4;
% r = lengthzeros/2/lengthpuresignal; % r for generate tukey window
r=0.3;

flagNewTest = 1;

%% parameters of 33500 waveform generator
Address_33500 = '10';
numFreqs = length(fvect);
burstPeriod = 20; % s
pausePeriod = 3; % s

for speaker_id = ["SV_1", 'SV_2', 'SV_3', 'SV_4', 'SV_5', 'SV_6', 'SV_7', 'SV_8', 'SV_9', 'SV_10']
    shadow_audio_path = [data_root data_type '/' speaker_id '/' 'combine.wav'];
    shadow_audio_path = string(join(shadow_audio_path,''));
    [full_shadow_audio, Fs_shadow] = audioread(shadow_audio_path);
    %plot(shadow_audio)
    %plot(shadow_audio(1:length(shadow_audio)/2))
    quater = length(full_shadow_audio)/4;
    disp(shadow_audio_path);

    for i = 0:3
        shadow_audio = full_shadow_audio(1+i*quater:(i+1)*quater);

        %plot(shadow_audio)
        shadow_audio = [zeros(lengthzeros,1);shadow_audio;zeros(lengthzeros,1)];
        sRate_33500_shadow = aFs_shadow*Fs_shadow;

        %% interpolation

        x_shadow = (1:length(shadow_audio))';
        xi_shadow = (1/aFs_shadow:1/aFs_shadow:length(shadow_audio))';
        yi_shadow = interp1q(x_shadow,shadow_audio,xi_shadow)';
        yi_shadow(isnan(yi_shadow))=0;
        yi_shadow = yi_shadow/abs(max(yi_shadow));
        %plot(yi_shadow);
        %% Clear MATLAB workspace of any previous instrument connections
        instrreset;
        %             lengthArb=5248000;
        lengthArb_shadow = length(yi_shadow);
        t = (1:lengthArb_shadow)/sRate_33500_shadow;
        fgen = LinkTo33500_GPIB(Address_33500,lengthArb_shadow);
        name_shadow = 'audioShadow';
        %% Sweeping Measurement
        if flagNewTest~=0
        % create waitbar for sweeping
            for ifc = 1:length(fvect)
                fc = fvect(ifc);
                Mod1 = m*yi_shadow.*cos(2*pi*fc*t);
                winTukey = tukeywin(length(yi_shadow),r);
                Mod2 = Mod1 + winTukey'.*cos(2*pi*fc*t);
                exciteErrorBit = direct_arbitraryTo33500_WaveformSend(Mod2,fgen,name_shadow,port,ampExcite,sRate_33500_shadow,burstPeriod);
                pause(14);
                %                     waveSendErrorBit = simultaneous_arbitraryTo33500_WaveformSend(yi,Mod2,fgen,name,name_shadow);
                %                     if ~exciteErrorBit % if exciting works
                %                         pause(pausePeriod);
                %                     else % if exciting error
                %                         msgbox('Error occurred trying to sending waveform','Error Message','error')
                %                         break
                %                     end
                ifc = ifc+1;
            end
        end
                    %% Close instrument connection
        %             fprintf(fgen,'OUTPUT1 OFF'); %Enable Output for channel 1
        %             fclose(fgen);
        toc
    end
end