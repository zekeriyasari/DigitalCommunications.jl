# This file includes the MonteCarlo simulation of PSK modulation scheme and compares 
# the numerical results with the theoretical results. 

using DigitalCommunications 
using Plots 

# Settings
pulse = RectangularPulse()          # Modulation pulse 
fs = 10                             # Samling frequency 
ts = 1 / fs                         # Sampling period 
tb = pulse.duration                 # Pulse duration 
k = 3                               # Bits per symbol 
M = 2^k                             # Costellation size 
nsymbols = Int(1e6)                 # Number of symbols 
ebno = collect(0 : 10)              # Energy per bit to noise power spectral density ratio 
esno = ebno .+ 10 * log10(k)        # Energy per symbol to noise power spectral densit ratio.

# Communcation system components  
gen = SymbolGenerator(nsymbols, M) 
modulator = Modulator(QAM(M), RectangularPulse(), ts)
channel = AWGNChannel(1., ts, tb)
detector = Detector(modulator(1:M))

# Monte Carlo simulation 
message = gen.symbols  
symerr = zeros(length(esno))
for i in 1 : length(symerr)
    channel.esno = esno[i]  # Update channel noise level 
    mbar = message |> modulator |> channel |> detector  # Run communication system 
    symerr[i] = sum(mbar .!= message) / length(message)  # Symbol error rate 
end

# Plots
plt = plot(title="$M-PSK", xlabel="ebno [dB]", ylabel="Pe") 
plot!(ebno, berqam.(esno, M), marker=:circle, yscale=:log10, label="theoretical")
plot!(ebno, symerr, marker=:circle, yscale=:log10, label="montecarlo")
