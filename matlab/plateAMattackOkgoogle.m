% Test Dolphine attack huawei voice control system using ultrasonic guided
% wave _ Normalmode
% % This program illustrates the use of 33500B waveform. Agilent VISA will be used for
% communicating with your instrument, please ensure that it is installed.
%
% This script was tested with a google pixel.
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
% [OkGoogle,Fs] = audioread('googleTTS_okgoogle.m4a');
% OKGoogleCut = OkGoogle(2.2e5:2.9e5,2);
% namepre = 'OkGgl';
% lengthpuresignal = length(OKGoogleCut);
% lengthzeros = 1e4;
% r = lengthzeros/lengthpuresignal; % r for generate tukey window
% OKGoogle1 = [zeros(lengthzeros,1);OKGoogleCut;zeros(lengthzeros,1)];


% [OkGoogle,Fs] = audioread('okgoogletakeapicture.m4a');
% OKGoogleCut = [OkGoogle(2.6e5:3.1e5,2);zeros(1e4,1);OkGoogle(3.1e5:3.6e5,2)];
% [OkGoogle,Fs] = audioread('okgooglecall.m4a');
% OKGoogleCut = [OkGoogle(1.226e5:1.761e5,2);zeros(1e4,1);OkGoogle(1.761e5:3.427e5,2)];


commandsOrignal = load('normOkGooglecommands.mat');
OKGoogle1 = commandsOrignal.OkGoogle;
% Ncoms = 1;
% comd = OKGoogle1(9.5e4:end);
% if Ncoms >1
%     for i = 1:(Ncoms-1)
%         OKGoogle1 = [OKGoogle1;comd];
%     end
% end
% % six commands
% handles.commandsOrignal.OkGglCall;
% handles.commandsOrignal.OkGglPic;
% handles.commandsOrignal.OkGglSelfie;
% handles.commandsOrignal.OkGglAir;
% handles.commandsOrignal.OkGglRdMsg;
% handles.commandsOrignal.OkGglVolTo3;
% handles.commandsOrignal.OkGoogle;
% load('D:\UNL\[Work] VC attack\GUI_VCattack\Records\OkGglReadMsgs.mat');
% load('D:\UNL\[Work] VC attack\GUI_VCattack\Records\OkGoogleOrignal.mat');

% OKGoogle1 = OkGglReadMsgs;
Fs = 48e3;
namepre = 'OkGgltest';

lengthzeros = 1e4; % from the pre-process of command orignal
r = lengthzeros / (length(OKGoogle1)-2*lengthzeros);

sRate = aFs*Fs;

% parameters of 33500 waveform generator
Address_33500 = '10';
sRate_33500 = sRate;
ampExcite = 9; % Vpp
% f_end = 28e3; % sweep frequency Hz
% delta_f = 100e2;
% f_start = 28e3;
% fvect = f_start:delta_f:f_end;
fvect = [28].*1e3;
numFreqs = length(fvect);
burstPeriod = 8; % s
pausePeriod = 16; % s


%interpolation x5
x = (1:length(OKGoogle1))';
xi = (1/Fs:1/aFs:length(OKGoogle1))';
yi = interp1q(x,OKGoogle1,xi)';
yi = yi/abs(max(yi));
lengthArb = length(yi);
t = (1:lengthArb)/sRate_33500;

% for AM modulation
m = 0.9;



%% Link
% Clear MATLAB workspace of any previous instrument connections
instrreset;
fgen = LinkTo33500_GPIB(Address_33500,lengthArb);

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
            name = [namepre];
%         else
%             msgbox('Too many fc is employed','Error Message','error')
%             break
%         end
        waveSendErrorBit = arbitraryTo33500_WaveformSend(Mod2,fgen,name);
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
        exciteErrorBit = arbitraryTo33500_Burst(fgen,ampExcite,sRate_33500,name,burstPeriod);
        if ~exciteErrorBit % if exciting works
            pause(pausePeriod);
        else % if exciting error
            msgbox('Error occurred trying to exciting signal','Error Message','error')
            break
        end
        fprintf(fgen,'OUTPUT1 OFF'); %Enable Output for channel 1
        %     pause(burstPeriod);

        ifc = ifc+1;
        
    end
    %get rid of message box
    figure(hwait)
    delete(hwait);
end
    %% Close instrument connection
    % fprintf(fgen,'OUTPUT1 OFF'); %Enable Output for channel 1
    fclose(fgen);
    toc
    figure;
