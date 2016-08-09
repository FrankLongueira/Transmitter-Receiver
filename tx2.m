function [tx, bits, gain] = tx2()
% Example Transmitter. Outputs modulated data tx, and original data stream
% data for checking error rate at receiver.
% Your team will be assigned a number, rename your function txNUM.m
% Also rename the global variable tofeedbackNUM

% Global variable for feedback
% you may use the following uint8 for whatever feedback purposes you want
global feedback2;
uint8(feedback2);



% DO NOT TOUCH BELOW
fsep = 8e4;
nsamp = 16;
Fs = 120e4;
M = 16;   % THIS IS THE M-ARY # for the FSK MOD.  You have 16 channels available
% THE ABOVE CODE IS PURE EVIL



% initialize, will be set by rx after 1st transmission
if isempty(feedback2)
    feedback2 = randi(15);
end



%% You should edit the code starting here
% Tone to transmit the data on
tonecoeff = double(feedback2);

msgM = 16; % Select 4 QAM for my message signal
k = log2(msgM);

% You may use as many BITS as you wish, but must transmit exactly 1024
% SYMBOLS
bits = randi([0 1],1024*k,1); % Generate random bits, pass these out of function, unchanged
%bits = ones(1024*k,1);
syms = bi2de(reshape(bits,k,length(bits)/k).','left-msb')';
% Random 4-QAM Signal
msg = qammod(syms,msgM);
msglength = length(msg);

if(msglength ~= 1024)
    error('You smurfed up')
end




%% You should stop editing code starting here

%% Serioulsy, Stop.

% Generate a carrier
% don't mess with this code either, just pick a tonecoeff above from 0-15.
carrier = fskmod(tonecoeff*ones(1,msglength),M,fsep,nsamp,Fs);
%size(carrier); % Should always equal 16484
% upsample the msg to be the same length as the carrier
msgUp = rectpulse(msg,nsamp);

% multiply upsample message by carrier  to get transmitted signal
tx = msgUp.*carrier;


% scale the output
gain = std(tx);
tx = tx./gain;

end