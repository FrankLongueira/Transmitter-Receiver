function [numCorrect] = rx2(sig, bits, gain)
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
global feedback2;
uint8(feedback2);

% in this example, just using feedback to set the freq index
tonecoeff = feedback2;

%% I don't recommend touching the code below
% Generate a carrier
carrier = fskmod(tonecoeff*ones(1,1024),M,fsep,nsamp,Fs);
rx = sig.*conj(carrier).*gain;
rx = intdump(rx,nsamp);
%% Recover your signal here

msgM = 16;
rxMsg = qamdemod(rx,msgM);

rx1 = de2bi(rxMsg,'left-msb'); % Map Symbols to Bits
rx2 = reshape(rx1.',numel(rx1),1);

rxBits = de2bi(rx2);
rxBits = rxBits(:);

% Check the BER. If zero BER, output the # of correctly received bits.
ber = biterr(rxBits, bits);

if ber == 0
    %disp('Sucessful frame User 2')
    numCorrect = length(bits);
else
   % scatterplot(rx)
end


% set the new value for the feedback here
% You probably want to do somehting more intelligent

feedback2 = randi(15);
%feedback2 = 1; %feedback2+1;
end