# This file includes the MonteCarlo simulation of ASK modulation scheme and compares 
# the numerical results with the theoretical results. 

using DigitalCommunications 
using Plots 

# Simulation parameters 
k = 3
M = 2^k 
nsymbols = Int(1e6) 
nbits = k * nsymbols
Ep = 100.                       # Modulating pulse energy. 
ebno = collect(0 : 10)          # Snr per bit 
esno = ebno .+ 10 * log10(k)    # Snr ber symbol  

# Communcation system components  
gen = BitGenerator(nbits) 
coding = GrayCoding(M)
modulator = Modulator(PAM(M))
channel = AWGNChannel() 
detector = Detector(alphabet(modulator))

# Monte Carlo simulation 
message = coding(gen.bits)  # Message signal 
symerr = zeros(length(esno))
for i in 1 : length(symerr)
    channel.esno = esno[i]  # Update channel snr
    mbar = gen.bits |> coding |> modulator |> channel |> detector  # Extracted message signal 
    symerr[i] = sum(mbar .!= message) / length(message)  # Symbol error rate 
end

# Plots
plt = plot(title="$M-PAM", xlabel="ebno [dB]", ylabel="Pe") 
plot!(ebno, berpam.(ebno, M), marker=:circle, yscale=:log10, label="theoretical")
plot!(ebno, symerr, marker=:circle, yscale=:log10, label="montecarlo")
