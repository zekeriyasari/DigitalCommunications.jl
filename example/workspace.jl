# This file includes the MonteCarlo simulation of PSK modulation scheme and compares 
# the numerical results with the theoretical results. 

using DigitalCommunications 
using Plots 

# Simulation parameters 
k = 3 
M = 2^k 
nsymbols = Int(1e6) 
nbits = k * nsymbols
γb = collect(0 : 10)        # Snr per bit 
γs = γb .+ 10 * log10(k)    # Snr ber symbol  

# Communcation system components  
gen = Generator(nbits) 
modulator = Modulator(PSK(), M)
channel = AWGNChannel(1) 
detector = MLDetector(signalset(modulator))

# Monte Carlo simulation 
message = mapstream(modulator, gen.bits)  # Message signal 
symerr = zeros(length(γs))
for i in 1 : length(symerr)
    channel.snr = γs[i]  # Update channel snr
    mbar = gen.bits |> modulator |> channel |> detector  # Extracted message signal 
    symerr[i] = sum(mbar .!= message) / length(message)  # Symbol error rate 
end

# Plots
plt = plot(title="$M-PSK", xlabel="γb [dB]", ylabel="Pe") 
plot!(γb, berpsk.(γs, M), marker=:circle, yscale=:log10, label="theoretical")
plot!(γb, symerr, marker=:circle, yscale=:log10, label="montecarlo")
