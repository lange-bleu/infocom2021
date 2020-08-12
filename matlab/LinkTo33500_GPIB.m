function fgen = LinkTo33500_GPIB(IP,lengthArb)

% voffset = 0;
vAddress = ['GPIB0::' IP '::INSTR']; %build visa address string to connect
fgen = visa('AGILENT',vAddress); %build IO object
fgen.Timeout = 60; %set IO time out

if nargin == 2
%calculate output buffer size
buffer = lengthArb*8;
set (fgen,'OutputBufferSize',(buffer+125));
end
% open connection to 33500A/B waveform generator
try
   fopen(fgen);
catch exception %problem occurred throw error message
    uiwait(msgbox('Error occurred trying to connect to the 33522, verify correct IP address','Error Message','error'));
    rethrow(exception);
end

% %Query Idendity string and report
% fprintf (fgen, '*IDN?');
% idn = fscanf (fgen);
% fprintf (idn);
% fprintf ('\n\n');

%Reset instrument
% fprintf (fgen, '*RST');



end