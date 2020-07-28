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
%% Initialization
flagNewTest = 1;
aFs = 4;
% [mixed_audio,Fs] = audioread('speakerA.wav');
% OkGoogle1 = OkGoogle(2.1e5:3.1e5,2);
% 
% % [HeyXiaoE,Fs] = audioread('interview���СE.m4a');
% % HeyXiaoE1 = HeyXiaoE(9524:26160,2);
% 
% lengthpuresignal = length(OkGoogle1);
% lengthzeros = 1e4;
% r = lengthzeros/2/lengthpuresignal; % r for generate tukey window
% OkGoogle1 = [zeros(lengthzeros,1);OkGoogle1;zeros(lengthzeros,1)];

%% set python env
% pe = pyversion('executable','D:\software\Anaconda3\envs\py3.6\python.exe');
% [v, e, isloaded] = pyversion;
% if ~isloaded
%     pyversion D:\software\Anaconda3\envs\py3.6\python.exe
% end
% 
mixed_audio_path='utils/speakerA.wav';
% 
% args_info = py.dict(pyargs('config' , 'config/config.yaml',...
%     'embedder_path','model/embedder.pt',...
%     "checkpoint_path", 'enhance_my_voice/chkpt_201000.pt',...
%     'mixed_file','utils/speakerA.wav',...
%     'reference_file',mixed_audio_path,...
%     'out_dir','output'));
% 
% args_info=struct(args_info);

%% play mixed_audio
[y, fs] = audioread(mixed_audio_path);
soundsc(y, fs);
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

%% retrieve mask_audio via python module
% [own_path, ~, ~] = fileparts(mfilename('fullpath'));
% module_path = fullfile(own_path, '..');
% python_path = py.sys.path;
% if count(python_path, module_path) == 0
%     insert(python_path, int32(0), module_path);
% end
% 
% if count(py.sys.path,'D:\\papers\\infocom2021') == 0
%     insert(py.sys.path,int32(0),'D:\\papers\\infocom2021');
% end
% py.print('hello, python!')

% py.importlib.import_module('utils.hparams')
% import py.utils.hparams.HParam

% mask_audio = py.inference_matlab.main(args_info);

mask_audio=y;
%% emit ultrasound
lengthpuresignal = length(mask_audio);
lengthzeros = 1e4;
r = lengthzeros/2/lengthpuresignal; % r for generate tukey window
mask_audio = [zeros(lengthzeros,1);mask_audio;zeros(lengthzeros,1)];

lengthpuresignal = length(mask_audio);
lengthzeros = 1e4;
r = lengthzeros/2/lengthpuresignal; % r for generate tukey window
mask_audio = [zeros(lengthzeros,1);mask_audio;zeros(lengthzeros,1)];


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
xi = (1/aFs:1/aFs:length(OkGoogle1))';
% yi = OkGoogle1;
% yi = yi/max(abs(yi));
yi = interp1q(x,OkGoogle1,xi)';
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