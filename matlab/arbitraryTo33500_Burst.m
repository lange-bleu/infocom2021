function errorbit = arbitraryTo33500_Burst(fgen,amp,sRate,name,burstPeriod)
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

%Reset instrument
fprintf (fgen, '*RST');
%Set Burst State
    fprintf (fgen, [':BURSt:STATe ON']);
    % fprintf (fgen, ['BURS:NCYC 3']);
    fprintf (fgen, ['BURS:INT:PERiod ' num2str(burstPeriod)]);

    
% command = ['SOURce1:FUNCtion:ARBitrary ' name];
% %fprintf(fgen,'SOURce1:FUNCtion:ARBitrary GPETE'); % set current arb waveform to defined arb testrise
% fprintf(fgen,command); % set current arb waveform to defined arb testrise
command = ['MMEM:LOAD:DATA1 "INT:\' name '.arb"'];%store arb in intermal NV memory
fprintf(fgen,command);
command = ['SOURce1:FUNCtion:ARBitrary "INT:\' name '.arb"'];
fprintf(fgen,command);
% MMEM:LOAD:DATA "Int:\Builtin\HAVERSINE.arb"
% FUNC:ARB "Int:\Builtin\HAVERSINE.ARB"

command = ['SOURCE1:FUNCtion:ARB:SRATe ' num2str(sRate)]; %create sample rate command
fprintf(fgen,command);%set sample rate
fprintf(fgen,'SOURce1:FUNCtion ARB'); % turn on arb function
command = ['SOURCE1:VOLT ' num2str(amp)]; %create amplitude command
fprintf(fgen,command); %send amplitude command
fprintf(fgen,'SOURCE1:VOLT:OFFSET 0'); % set offset to 0 V
fprintf(fgen,'OUTPUT1 ON'); %Enable Output for channel 1


%Read Error
fprintf(fgen, 'SYST:ERR?');
errorstr = fscanf (fgen);
% error checking
if strncmp (errorstr, '+0,"No error"',13)
   errorbit = 0;
else
   errorcheck = ['Error reported: ', errorstr];
   fprintf (errorcheck)
   errorbit = 1;
end

end