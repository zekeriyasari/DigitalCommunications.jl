# This file illustrates the simulation of Q-PSK signalling. The simulation is performed using 
# waveform AWGN channel. 

using Plots 
using FFTW 
using LinearAlgebra 
using Statistics 
using DigitalCommunications

# Settings 
k = 2                                   # Bits per symbol 
M = 2^k                                 # Constellation size 
T = 1.                                  # Symbol duration 
f = 1 / T                               # Symbols per second 
Eg = 1                                  # Modulation pulse energy 
fs = 10                                 # Sampling frequency 
ts = 1 / fs                             # Sampling period 
t = 0 : ts : T - ts                     # Time vector for symbol duration 
l = length(t)                           # Number of samples per symbol
g(t) = 0 ≤ t ≤ T ? sqrt(Eg / T) : 0     # Modulation pulse 
nsymbols = Int(1e6)                     # Number of symbols 

# Define basis
basis = [
    t -> g(t) / sqrt(Eg) 
]
alphabet = [
    [1 + 0im], 
    [0 + 1im], 
    [-1 + 0im], 
    [0 - 1im], 
]
basisvals = map(base -> base.(t), basis) 
references = map(1 : M) do mi 
    Ai = alphabet[mi] * sqrt(Eg)
    sum(Ai .* basisvals)
end 

# Simulate the system 
ebno = collect(0 : 1 : 10)
esno = ebno .+ 10 * log10(k) 
m = rand(1 : M, nsymbols)
tx = map(m) do mi 
    Ai = alphabet[mi] * sqrt(Eg) 
    sum(Ai .* basisvals)
end 
Es = mean(txi -> sum(abs.(txi).^2) * ts, tx)
symerr = zeros(length(esno)) 
for i = 1 : length(symerr)
    # Generate noise 
    σ = sqrt(Es * fs / 2 / (10^(esno[i] / 10))) 
    n = [σ * (randn(l) + 1im * randn(l)) for i = 1 : length(tx)]
    # Corrupt transmitted signal 
    rx = tx + n 
    # Detect symbols 
    mr = map(rx) do rxi 
        argmax(map(reference -> real(rxi ⋅ reference), references))
    end
    # Calculate symbol 
    ber = sum(m .!= mr) / length(m)
    symerr[i] = ber 
end 

# Plots 
plot(ebno, symerr, marker=:circle, yscale=:log10, label="montecarlo")
plot!(ebno, berpsk.(esno, M), marker=:circle, yscale=:log10, label="theoretical")
title!("$M-PSK")
xlabel!("EbNo") 
ylabel!("Pe")
