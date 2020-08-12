function errorbit = simultaneous_arbitraryTo33500_WaveformSend(arb,arb_shadow,fgen,name,name_shadow)
% This function connects to a 33500A/B waveform generator and sends it an
% arbitrary waveform from Matlab via GPIB. The input arguments are as
% follows:
% arb --> a vector of the waveform points that will be sent to a 33500A/B
% waveform generator
% fgen --> Visa/GPIB object of the 33500A/B that you created
% amp --> amplitude of the arb waveform as Vpp
% sRate --> sample rate of the arb waveform
% name --> The same of the arb waveform as a string
% Note: this function requires the instrument control toolbox
% BurstPeriod--> Burst Period unit(seconds)

% %create waitbar for sending waveform to 33500
% mes = 'Connected to 33500B sending waveforms.....';
% h = waitbar(0,mes);

%Reset instrument
fprintf (fgen, '*RST');


%make sure waveform data is in column vector
if isrow(arb) == 0
    arb = arb';
    arb_shadow = arb_shadow';
end

%set the waveform data to single precision
arb = single(arb);
arb_shadow = single(arb_shadow);

%scale data between 1 and -1
mx = max(abs(arb));
arb = (1*arb)/mx;

mx_shadow = max(abs(arb_shadow));
arb_shadow = (1*arb_shadow)/mx_shadow;

% %update waitbar
% waitbar(.1,h,mes);

%send waveform to 33500
fprintf(fgen, ['SOURce1:DATA:VOLatile:CLEar']); %Clear volatile memory
fprintf(fgen, ['SOURce2:DATA:VOLatile:CLEar']); %Clear volatile memory

fprintf(fgen, 'FORM:BORD SWAP');  %configure the box to correctly accept the binary arb points

arbBytes = num2str(length(arb) * 4); %# of bytes
header= ['SOURce1:DATA:ARBitrary ' name ', #' num2str(length(arbBytes)) arbBytes]; %create header
binblockBytes = typecast(arb, 'uint8');  % convert datapoints to binary before sending
fwrite(fgen, [header binblockBytes], 'uint8'); % combine header and datapoints then send to instrument

arbBytes_shadow = num2str(length(arb_shadow) * 4); %# of bytes
header_shadow= ['SOURce2:DATA:ARBitrary ' name_shadow ', #' num2str(length(arbBytes_shadow)) arbBytes_shadow]; %create header
binblockBytes_shadow = typecast(arb_shadow, 'uint8');  % convert datapoints to binary before sending
fwrite(fgen, [header_shadow binblockBytes_shadow], 'uint8'); % combine header and datapoints then send to instrument

fprintf(fgen, '*WAI');   % Make sure no other commands are exectued until arb is done downloadin
%Set desired configuration for channel 1



command = ['SOURce1:FUNCtion:ARBitrary ' name];
fprintf(fgen,command); % set current arb waveform to defined arb testrise
command = ['MMEM:STOR:DATA1 "INT:\' name '.arb"']; %store arb in intermal NV memory
fprintf(fgen,command);

command = ['SOURce2:FUNCtion:ARBitrary ' name_shadow];
fprintf(fgen,command); % set current arb waveform to defined arb testrise
command = ['MMEM:STOR:DATA2 "INT:\' name_shadow '.arb"']; %store arb in intermal NV memory
fprintf(fgen,command);
% 
% command = ['SOURCE1:FUNCtion:ARB:SRATe ' num2str(sRate)]; %create sample rate command
% fprintf(fgen,command);%set sample rate
% fprintf(fgen,'SOURce1:FUNCtion ARB'); % turn on arb function
% command = ['SOURCE1:VOLT ' num2str(amp)]; %create amplitude command
% fprintf(fgen,command); %send amplitude command
% fprintf(fgen,'SOURCE1:VOLT:OFFSET 0'); % set offset to 0 V
% fprintf(fgen,'OUTPUT1 ON'); %Enable Output for channel 1
% % fprintf('Arb waveform downloaded to channel 1\n\n') %print waveform has been downloaded
% % MMEM:DEL "INT:\MySetup.sta"
% 
% 

%Read Error
fprintf(fgen, 'SYST:ERR?');
errorstr = fscanf (fgen);
% error checking
% disp('3333333333333');
if strncmp (errorstr, '+0,"No error"',13)
%    errorcheck = 'Arbitrary waveform generated without any error\n';
%    fprintf (errorcheck)
   errorbit = 0;
else
    msgbox(errorstr,'Error Message','error')
            
%    errorcheck = ['Error reported: ', errorstr];
%    fprintf (errorcheck)
   errorbit = 1;
end
% disp('22222222222222');
end