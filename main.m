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

data_root = './user_case_datasets/test/';
% data_noise=["joint","babble","volvo"];
data_noise = ["conversation", "babble","volvo"];
port=1;
ampExcite = 4; % Vpp
% for AM modulation
m = 0.7;

f_end = 32e3; % sweep frequency Hz
delta_f = 1e2;
f_start = 26e3;
% fvect = [f_start:delta_f:f_end];
fvect = [25.3].*1e3;
aFs_shadow = 4;


lengthzeros = 1e4;
% r = lengthzeros/2/lengthpuresignal; % r for generate tukey window
r=0.3;

flagNewTest = 1;

%% parameters of 33500 waveform generator
Address_33500 = '10';
numFreqs = length(fvect);
burstPeriod = 10; % s
pausePeriod = 16; % s

for audio_file_index=1:15
    for noise_index=1:3
        mixed_audio_dir=[data_root 'SV_' int2str(audio_file_index) '/' data_noise(noise_index) '/*mixed-48k.wav'];
        shadow_audio_dir=[data_root 'SV_' int2str(audio_file_index) '/' data_noise(noise_index) '/*hide2-48k.wav'];
        if noise_index == 2
            shadow_audio_dir=[data_root 'SV_' int2str(audio_file_index) '/' data_noise(noise_index) '/*hide3-48k.wav'];
        end
        mixed_audio_dir = string(join(mixed_audio_dir,''));
        shadow_audio_dir = string(join(shadow_audio_dir,''));
        mixed_audio_path = dir(mixed_audio_dir);
        shadow_audio_path = dir(shadow_audio_dir);
        
        %for file_index=1:length(shadow_audio_path)
        for file_index=1:6
            mixed_audio_file=[mixed_audio_path(file_index).folder '\' mixed_audio_path(file_index).name];
            shadow_audio_file=[shadow_audio_path(file_index).folder '\' shadow_audio_path(file_index).name];
            
            %% play mixed_audio
            [mixed_audio, Fs_mixed] = audioread(mixed_audio_file);
            %             shadow_audio_file='utils/google.mp3';
            [shadow_audio, Fs_shadow] = audioread(shadow_audio_file);
            
            %             soundsc(mixed_audio, Fs_mixed);
            
            mixed_audio = [zeros(lengthzeros,1);mixed_audio;zeros(lengthzeros,1)];
            shadow_audio = [zeros(lengthzeros,1);shadow_audio;zeros(lengthzeros,1)];
            sRate_33500_shadow = aFs_shadow*Fs_shadow;
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
            x = (1:length(mixed_audio))';
            xi = (1/aFs_shadow:1/aFs_shadow:length(mixed_audio))';
            yi = interp1q(x,mixed_audio,xi)';
            yi(isnan(yi))=0;
            yi = yi/abs(max(yi));
            
            x_shadow = (1:length(shadow_audio))';
            xi_shadow = (1/aFs_shadow:1/aFs_shadow:length(shadow_audio))';
            yi_shadow = interp1q(x_shadow,shadow_audio,xi_shadow)';
            yi_shadow(isnan(yi_shadow))=0;
            yi_shadow = yi_shadow/abs(max(yi_shadow));
            
            %% Clear MATLAB workspace of any previous instrument connections
            instrreset;
            %             lengthArb=5248000;
            lengthArb_shadow = length(yi_shadow);
            t = (1:lengthArb_shadow)/sRate_33500_shadow;
            fgen = LinkTo33500_GPIB(Address_33500,lengthArb_shadow);
            
            %             name = shadow_audio_path(file_index).name(1:end-4);
            name = 'audioMixed';
            name_shadow = 'audioShadow';
            %% Sweeping Measurement
            if flagNewTest~=0
                % create waitbar for sweeping
                hwait = waitbar(0,' Please wait >>>>>>>>');
                for ifc = 1:length(fvect)
                    fc = fvect(ifc);
                    % exciting
                    %     t = (1:length(yi))/(sRate);
                    Mod1 = m*yi_shadow.*cos(2*pi*fc*t);
                    winTukey = tukeywin(length(yi_shadow),r);
                    Mod2 = Mod1 + winTukey'.*cos(2*pi*fc*t);
                    %         if numFreqs <=10
                    %         else
                    %             msgbox('Too many fc is employed','Error Message','error')
                    %             break
                    %         end
                    %         waveSendErrorBit = arbitraryTo33500_WaveformSend(Mod2,fgen,name);
                    %                     waveSendErrorBit = port_arbitraryTo33500_WaveformSend(Mod2,fgen,name,port);
                    waveSendErrorBit = simultaneous_arbitraryTo33500_WaveformSend(yi,Mod2,fgen,name,name_shadow);
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
                    %                     exciteErrorBit = port_arbitraryTo33500_Burst(fgen,ampExcite,sRate_33500,name,burstPeriod,port);
                    exciteErrorBit = simultaneous_arbitraryTo33500_Burst(fgen,ampExcite,sRate_33500_shadow,name,name_shadow,burstPeriod);
%                     if ~exciteErrorBit % if exciting works
%                         pause(pausePeriod);
%                     else % if exciting error
%                         msgbox('Error occurred trying to exciting signal','Error Message','error')
%                         break
%                     end
                    %                     fprintf(fgen,['OUTPUT' int2str(port) ' OFF']); %Enable Output for channel 1
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
