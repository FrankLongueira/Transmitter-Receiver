function [numCorrect] = rx1(sig, bits, gain)
%% Receive input sig, compute BER relative to bits

% DO NOT TOUCH BELOW
fsep = 8e4;
nsamp = 16;
Fs = 120e4;
M = 16;
%M = 4; fsep = 8; nsamp = 8; Fs = 32;

% THE ABOVE CODE IS PURE EVIL

numCorrect = 0; % initialize the # of correct Rx bits
% Global variable for feedback
global feedback1;
uint8(feedback1);

% in this example, just using feedback to set the freq index
tonecoeff = feedback1;

%% I don't recommend touching the code below
% Generate a carrier
carrier = fskmod(tonecoeff*ones(1,1024),M,fsep,nsamp,Fs);
rx = sig.*conj(carrier);
rx = intdump(rx,nsamp);
%% Recover your signal here

rxMsg = qamdemod(rx,4);

rx1 = de2bi(rxMsg,'left-msb'); % Map Symbols to Bits
rx2 = reshape(rx1.',numel(rx1),1);

rxBits = de2bi(rx2);
rxBits = rxBits(:);

% Check the BER. If zero BER, output the # of correctly received bits.
ber = biterr(rxBits, bits);

if ber == 0
  %  disp('Sucessful frame User 1')
    numCorrect = length(bits);
else 
   % scatterplot(rx); 
end


% set the new value for the feedback here
% You probably want to do somehting more intelligent

feedback1 = feedback1 + 1;

end