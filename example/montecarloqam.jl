# This file includes the MonteCarlo simulation of QAM modulation scheme and compares 
# the numerical results with the theoretical results. 

using DigitalCommunications 
using Plots 

# Simulation parameters 
k = 4 
M = 2^k 
nsymbols = Int(1e6) 
nbits = k * nsymbols
γb = collect(0 : 10)        # Snr per bit 
γs = γb .+ 10 * log10(k)    # Snr ber symbol  

# Communcation system components  
gen = Generator(nbits) 
modulator = Modulator(QAM(M))
channel = AWGNChannel(1) 
detector = MLDetector(alphabet(modulator))

# Monte Carlo simulation 
message = stream_to_symbols(modulator, gen.bits)  # Message signal 
symerr = zeros(length(γs))
for i in 1 : length(symerr)
    channel.snr = γs[i]  # Update channel snr
    mbar = gen.bits |> modulator |> channel |> detector  # Extracted message signal 
    symerr[i] = sum(mbar .!= message) / length(message)  # Symbol error rate 
end

# Plots
plt = plot(title="$M-QAM", xlabel="γb [dB]", ylabel="Pe") 
plot!(γb, berqam.(γb, M), marker=:circle, yscale=:log10, label="theoretical")
plot!(γb, symerr, marker=:circle, yscale=:log10, label="montecarlo")
