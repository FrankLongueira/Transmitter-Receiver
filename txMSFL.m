% Matthew Smarsch and Frank Longueira
% Comm Theory Final Project
% Transmitter

function [tx, bits, gain] = txMSFL()
% Example Transmitter. Outputs modulated data tx, and original data stream
% data for checking error rate at receiver.
% Your team will be assigned a number, rename your function txNUM.m
% Also rename the global variable tofeedbackNUM

% Global variable for feedback
% you may use the following uint8 for whatever feedback purposes you want
global feedbackMSFL;
uint8(feedbackMSFL);

% DO NOT TOUCH BELOW
fsep = 8e4;
nsamp = 16;
Fs = 120e4;
M = 16;   % THIS IS THE M-ARY # for the FSK MOD.  You have 16 channels available
% THE ABOVE CODE IS PURE EVIL



% initialize, will be set by rx after 1st transmission
if isempty(feedbackMSFL)
    feedbackMSFL = bi2de([1 0 0 0 0 0 0 0],'left-msb');
end

binFB=de2bi(feedbackMSFL,8,'left-msb');

%% You should edit the code starting here
% Tone to transmit the data on
tonecoeff = bi2de(binFB(5:8),'left-msb');


if binFB(1:3) == [1 1 0]
    msgM = 64;
elseif binFB(1:3) == [0 1 0]
    msgM = 32;
elseif binFB(1:3) == [1 0 0]
    msgM = 16;
elseif binFB(1:3) == [0 0 1]
    msgM = 8;
else
    msgM = 4;
end
k = log2(msgM);

% You may use as many BITS as you wish, but must transmit exactly 1024
% SYMBOLS
%bits = randi([0 1],kerr*k,1); % Generate random bits, pass these out of function, unchanged
%bits = ones(1024*k,1);

%gfbits = gf(bits);

if msgM == 64
    kerr = 933;
    bits = randi([0 1],kerr*k,1); 
    bits2 = reshape(bits, kerr, []).';
    gfbits = gf(bits2);
    encBits = bchenc(gfbits, 1023, kerr);
elseif msgM == 32
    kerr = 903;
    bits = randi([0 1],kerr*k,1); 
    bits2 = reshape(bits, kerr, []).';
    gfbits = gf(bits2);
    encBits = bchenc(gfbits, 1023, kerr);
elseif msgM == 16
    kerr = 828;
    bits = randi([0 1],kerr*k,1);
    bits2 = reshape(bits, kerr, []).';
    gfbits = gf(bits2);
    encBits = bchenc(gfbits, 1023, kerr);
elseif msgM == 8
    kerr = 708;
    bits = randi([0 1],kerr*k,1);
    bits2 = reshape(bits, kerr, []).';
    gfbits = gf(bits2);
    encBits = bchenc(gfbits, 1023, kerr);
else
    kerr = 1003;
    bits = randi([0 1],kerr*k,1);
    bits2 = reshape(bits, kerr, []).';
    gfbits = gf(bits2);
    encBits = bchenc(gfbits, 1023, kerr);
end


encBits2 = double(encBits.x).';
syms = bi2de(encBits2,'left-msb');
Diff = 1024-length(syms);
syms2 = [syms; zeros(Diff,1)];
%syms = bi2de(reshape(encBits3,k,length(encBits2)/k).','left-msb')';

msg = qammod(syms2,msgM).';
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