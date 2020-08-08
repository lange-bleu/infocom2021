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

data_root = './audio_datasets/test/';
data_noise=["joint","conversation","babble","volvo"];
port=1;
ampExcite = 3; % Vpp
% for AM modulation
m = 0.7;

f_end = 32e3; % sweep frequency Hz
delta_f = 1e2;
f_start = 26e3;
% fvect = [f_start:delta_f:f_end];
fvect = [27.2].*1e3;
aFs = 4;


lengthzeros = 1e4;
% r = lengthzeros/2/lengthpuresignal; % r for generate tukey window
r=0.3;

flagNewTest = 1;

%% parameters of 33500 waveform generator
Address_33500 = '10';
numFreqs = length(fvect);
burstPeriod = 8; % s
pausePeriod = 16; % s

for audio_file_index=2:18
    for noise_index=1:4
        mixed_audio_dir=[data_root 'SV_' int2str(audio_file_index) '/' data_noise(noise_index) '/*mixed.wav'];
        shadow_audio_dir=[data_root 'SV_' int2str(audio_file_index) '/' data_noise(noise_index) '/*hide2-48k.wav'];
        mixed_audio_dir = string(join(mixed_audio_dir,''));
        shadow_audio_dir = string(join(shadow_audio_dir,''));
        mixed_audio_path = dir(mixed_audio_dir);
        shadow_audio_path = dir(shadow_audio_dir);
        
        for file_index=20
            mixed_audio_file=[mixed_audio_path(file_index).folder '\' mixed_audio_path(file_index).name];
            shadow_audio_file=[shadow_audio_path(file_index).folder '\' shadow_audio_path(file_index).name];
            
            %% play mixed_audio
            [mixed_audio, Fs_mixed] = audioread(mixed_audio_file);
%             shadow_audio_file='utils/google.mp3';
            [shadow_audio, Fs_shadow] = audioread(shadow_audio_file);
            
            %             soundsc(mixed_audio, Fs_mixed);
            
            shadow_audio = [zeros(lengthzeros,1);shadow_audio;zeros(lengthzeros,1)];
            sRate_33500 = aFs*Fs_shadow;
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
            
            
            %% interpolation
            x = (1:length(shadow_audio))';
            xi = (1/aFs:1/aFs:length(shadow_audio))';
            
            yi = interp1q(x,shadow_audio,xi)';
            yi(isnan(yi))=0;
            yi = yi/abs(max(yi));
            
            %% Clear MATLAB workspace of any previous instrument connections
            instrreset;
            %             lengthArb=5248000;
            lengthArb = length(yi);
            t = (1:lengthArb)/sRate_33500;
            fgen = LinkTo33500_GPIB(Address_33500,lengthArb);
            
%             name = shadow_audio_path(file_index).name(1:end-4);
            name = 'maskAudio';
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
            end
            %% Close instrument connection
            fclose(fgen);
            toc
        end
    end
end
