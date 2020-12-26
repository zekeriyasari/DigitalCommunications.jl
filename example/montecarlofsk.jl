# This file includes the MonteCarlo simulation of FSK modulation scheme and compares 
# the numerical results with the theoretical results. 

using DigitalCommunications 
using Plots; theme(:default)

# Simulation parameters 
k = 2
M = 2^k 
nsymbols = Int(1e6) 
nbits = k * nsymbols
ebno = collect(0 : 10)        # Snr per bit 
esno = ebno .+ 10 * log10(k)    # Snr ber symbol  

# Communcation system components  
gen = Generator(nbits) 
modulator = Modulator(FSK(M))
channel = AWGNChannel(1) 
detector = MLDetector(alphabet(modulator))

# Monte Carlo simulation 
message = stream_to_symbols(modulator, gen.bits)  # Message signal 
symerr = zeros(length(esno))
for i in 1 : length(symerr)
    channel.esno = esno[i]  # Update channel snr
    mbar = gen.bits |> modulator |> channel |> detector  # Extracted message signal 
    symerr[i] = sum(mbar .!= message) / length(message)  # Symbol error rate 
end

# Plots
plt = plot(title="$M-FSK", xlabel="esno [dB]", ylabel="Pe") 
plot!(esno, berfsk.(esno, M), marker=:circle, yscale=:log10, label="theoretical")
plot!(esno, symerr, marker=:circle, yscale=:log10, label="montecarlo")
