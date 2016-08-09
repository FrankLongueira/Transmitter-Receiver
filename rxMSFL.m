% Matthew Smarsch and Frank Longueira
% Comm Theory Final Project
% Receiver

function [numCorrect] = rxMSFL(sig, bits, gain)
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
persistent SNRmem
global feedbackMSFL;
uint8(feedbackMSFL);
binFB=de2bi(feedbackMSFL, 8, 'left-msb');


% in this example, just using feedback to set the freq index
tonecoeff = bi2de(binFB(5:8),'left-msb');

%% I don't recommend touching the code below
% Generate a carrier
carrier = fskmod(tonecoeff*ones(1,1024),M,fsep,nsamp,Fs);
rx = sig.*conj(carrier)*gain;
rx = intdump(rx,nsamp);
%% Recover your signal here

snrest = (-10*log10(abs(var(sig)-2)))+1;
SNRmem = [SNRmem snrest];
snr = round(mean(SNRmem))


if snr > 13
    feedbacktemp = [1 1 0 0 0 0 0 0]; %Use 64QAM, Nerr = 1023, Kerr = 933
elseif snr > 8
    feedbacktemp = [0 1 0 0 0 0 0 0]; %Use 32QAM, Nerr = 1023, Kerr = 708
elseif snr > 3
    feedbacktemp = [1 0 0 0 0 0 0 0]; %Use 16QAM Nerr = 1023 Kerr = 828
elseif snr > 0
    feedbacktemp = [0 0 1 0 0 0 0 0]; %Use 8QAM Nerr = 1023 Kerr = 708
else
    feedbacktemp = [0 0 0 0 0 0 0 0]; %Use 4QAM Nerr = 1023 Kerr = 1003
end

binFB=de2bi(feedbackMSFL, 8,'left-msb');

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

rxMsg = qamdemod(rx, msgM);

diff = 1024-1023;
rxMsg2 = rxMsg(1:end-diff);

rx1 = de2bi(rxMsg2,'left-msb'); % Map Symbols to Bits
rx2 = reshape(rx1.',numel(rx1),1);

rxBits = de2bi(rx2);
rxBits = rxBits(:).';
rxBits = reshape(rxBits, [], 1023);
gfrxBits = gf(rxBits);
if binFB(1:3) == [1 1 0]
    [decBits,err,ccode] = bchdec(gfrxBits, 1023, 933);
elseif binFB(1:3) == [0 1 0]
    [decBits,err,ccode] = bchdec(gfrxBits, 1023, 903);
elseif binFB(1:3) == [1 0 0]
    [decBits,err,ccode] = bchdec(gfrxBits, 1023, 828);
elseif binFB(1:3) == [0 0 1]
    [decBits,err,ccode] = bchdec(gfrxBits, 1023, 708);
else
    [decBits,err,ccode] = bchdec(gfrxBits, 1023, 1003);
end

decBits = double(decBits.x).';
decBits2 = reshape(decBits,[],1);

% Check the BER. If zero BER, output the # of correctly received bits.
ber = biterr(decBits2, bits);

if ber == 0
  %  disp('Sucessful frame User 1')
    numCorrect = length(bits);
else 
   ber
   % scatterplot(rx); 
end

channel = randi([0, 15]);
feedbacktemp(5:8) = de2bi(channel, 4, 'left-msb');
feedbackMSFL = bi2de(feedbacktemp,'left-msb');

end