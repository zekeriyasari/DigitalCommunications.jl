# This file includes the MonteCarlo simulation of QAM modulation scheme and compares 
# the numerical results with the theoretical results. 

using DigitalCommunications 
using Plots 

# Simulation parameters 
k = 4 
M = 2^k 
nsymbols = Int(1e6) 
nbits = k * nsymbols
ebno = collect(0 : 10)        # Snr per bit 
esno = ebno .+ 10 * log10(k)    # Snr ber symbol  

# Communcation system components  
gen = SymbolGenerator(nsymbols, M)
modulator = Modulator(QAM(M))
channel = AWGNChannel() 
detector = Detector(modulator(1:M))

# Monte Carlo simulation 
message = gen.symbols  # Message signal 
symerr = zeros(length(esno))
for i in 1 : length(symerr)
    channel.esno = esno[i]  # Update channel snr
    mbar = message |> modulator |> channel |> detector  # Extracted message signal 
    symerr[i] = sum(mbar .!= message) / length(message)  # Symbol error rate 
end

# Plots
plt = plot(title="$M-QAM", xlabel="ebno [dB]", ylabel="Pe") 
plot!(ebno, berqam.(ebno, M), marker=:circle, yscale=:log10, label="theoretical")
plot!(ebno, symerr, marker=:circle, yscale=:log10, label="montecarlo")
