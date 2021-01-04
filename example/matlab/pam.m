% MonteCarlo simulation of PAM signalling. 

clc 
clear 
close all 

% PARAMETESRS
k = 3;                      % Bits per symbol
M = 2^k;                    % Constallation size. 
nsymbols = 1e7;             % Number of symbols     
nbits = nsymbols * k;       % Number of bits 
EbNo = 10 : 20;             % EbNo in dB
snr = EbNo + 10 * log10(k); % Snr lebe in dB

% CHANNEL
% Note: For each SNR, the message signals are corrupted with the channel
% noise. The snr level of the channel determines the variance of the noise.
% which, in turn, is determined with respect to the signal power. See the
% man page of comm.AWGNChannel.
channel = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)');
errorcalc = comm.ErrorRate();

% MONTE CARLO SIMULATION
% Precomputing ...
msg = randi([0 M - 1], nsymbols, 1);    % Message signals. 
tx = pammod(msg, M);                    % Transmitted signal in baseband
% channel.SignalPower = norm(tx)^2 / length(tx); % Adjust the channel signal level.

% Simulate for different snr levels...
ber = zeros(3, length(EbNo));   
for i = 1 : length(EbNo)    
    reset(errorcalc);           % Reset the ber calculator
    channel.SNR = snr(i);       % Adjust channel snr    
    rx = channel(tx);           % Corruption of the message signal 
    extmsg = pamdemod(rx, M);   % Demodulation
    ber(:, i) = errorcalc(msg, extmsg); % Ber/Ser calculation.
end

% THEORETİCAL BER 
[bertheo, sertheo] = berawgn(EbNo, 'pam', M);

% PLOTS
semilogy(EbNo, ber(1, :), 'r*');
hold on 
semilogy(EbNo, sertheo);
title(strcat(num2str(M), '-PAM'));
xlabel('E_b/N_0 (dB)')
ylabel('P_e')
grid on 

