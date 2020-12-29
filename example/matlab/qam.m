% MonteCarlo simulation of PAM signalling. 

clc 
clear 
close all 

k = 2;
M = 2^k; 
nsymbols = 1000000;
nbits = nsymbols * k;
EbNo = -4 : 10;
snr = EbNo + 10 * log10(k);

channel = comm.VectorAWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)');
errorcalc = comm.ErrorRate();

msg = randi([0 M - 1], nsymbols, 1);
tx = qammod(msg, M);
channel.SignalPower = norm(tx)^2 / length(tx);
ber = zeros(3, length(EbNo));
for i = 1 : length(EbNo)
    reset(errorcalc);
    channel.SNR = snr(i);
    rx = channel(tx);
    extmsg = qamdemod(rx, M);
    ber(:, i) = errorcalc(msg, extmsg);
end

[bertheo, sertheo] = berawgn(EbNo, 'qam', M);

semilogy(EbNo, ber(1, :), 'r*');
hold on 
semilogy(EbNo, sertheo);
grid on 

