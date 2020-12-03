% MonteCarlo simulation of PAM signalling. 

clc 
clear 
close all 

k = 3;
M = 2^k; 
nsymbols = 10000000;
nbits = nsymbols * k;
EbNo = -4 : 20;
snr = EbNo + 10 * log10(k);

channel = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)');
errorcalc = comm.ErrorRate();

msg = randi([0 M - 1], nsymbols, 1);
tx = pammod(msg, M);
channel.SignalPower = norm(tx)^2 / length(tx); % Signal power = (M^2 - 1) / 3
ber = zeros(3, length(EbNo));
for i = 1 : length(EbNo)
    reset(errorcalc);
    channel.SNR = snr(i);
    rx = channel(tx);
    extmsg = pamdemod(rx, M);
    ber(:, i) = errorcalc(msg, extmsg);
end

[bertheo, sertheo] = berawgn(EbNo, 'pam', M);

semilogy(EbNo, ber(1, :), 'r*');
hold on 
semilogy(EbNo, sertheo);
grid on 

