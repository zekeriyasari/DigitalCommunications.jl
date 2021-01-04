# This file includes the MonteCarlo simulation of PSK modulation scheme and compares 
# the numerical results with the theoretical results. 

using DigitalCommunications 
using Plots 

# Simulation parameters 
k = 3 
M = 2^k 
nsymbols = Int(1e6) 
nbits = k * nsymbols
ebno = collect(0 : 10)         
esno = ebno .+ 10 * log10(k)    

# Communcation system components  
gen = SymbolGenerator(nsymbols, M) 
modulator = Modulator(PSK(M))
channel = AWGNChannel() 
detector = Detector(modulator(1:M))

# Monte Carlo simulation 
message = gen.symbols  
symerr = zeros(length(esno))
for i in 1 : length(symerr)
    channel.esno = esno[i]  # Update channel snr
    mbar = message |> modulator |> channel |> detector  # Extracted message signal 
    symerr[i] = sum(mbar .!= message) / length(message)  # Symbol error rate 
end

# Plots
plt = plot(title="$M-PSK", xlabel="ebno [dB]", ylabel="Pe") 
plot!(ebno, berpsk.(esno, M), marker=:circle, yscale=:log10, label="theoretical")
plot!(ebno, symerr, marker=:circle, yscale=:log10, label="montecarlo")
