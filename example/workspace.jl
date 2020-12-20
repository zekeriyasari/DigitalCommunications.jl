# This file includes the MonteCarlo simulation of PSK modulation scheme and compares 
# the numerical results with the theoretical results. 

using DigitalCommunications 
using Plots 

# Simulation parameters 
k = 2 
M = 2^k 
nsymbols = Int(1e6) 
nbits = k * nsymbols
ebno = collect(0 : 10)         
esno = ebno .+ 10 * log10(k)  

# Communcation system components  
gen = Generator(nbits) 
modulator = Modulator(ASK(M))
channel = AWGNChannel(EbNo(), k) 
detector = MLDetector(alphabet(modulator))

# Monte Carlo simulation 
message = stream_to_symbols(modulator, gen.bits)  # Message signal 
symerr = zeros(length(esno))
for i in 1 : length(symerr)
    channel.mode = EbNo(ebno[i] + 3)  # Update channel snr
    mbar = gen.bits |> modulator |> channel |> detector  # Extracted message signal 
    symerr[i] = sum(mbar .!= message) / length(message)  # Symbol error rate 
end

# Plots
plt = plot(title="$M-PSK", xlabel="ebno [dB]", ylabel="Pe") 
plot!(ebno, berask.(ebno, M), marker=:circle, yscale=:log10, label="theoretical")
plot!(ebno, symerr, marker=:circle, yscale=:log10, label="montecarlo")
display(plt)