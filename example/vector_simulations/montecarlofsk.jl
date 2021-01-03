# This file includes the MonteCarlo simulation of FSK modulation scheme and compares 
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
coding = GrayCoding(M)
modulator = VectorModulator(FSK(M))
channel = VectorAWGNChannel() 
detector = MLDetector(alphabet(modulator))

# Monte Carlo simulation 
message = coding(gen.bits)  # Message signal 
symerr = zeros(length(esno))
for i in 1 : length(symerr)
    channel.esno = esno[i]  # Update channel snr
    mbar = gen.bits |> coding |> modulator |> channel |> detector  # Extracted message signal 
    symerr[i] = sum(mbar .!= message) / length(message)  # Symbol error rate 
end

# Plots
plt = plot(title="$M-FSK", xlabel="esno [dB]", ylabel="Pe") 
plot!(esno, berfsk.(esno, M), marker=:circle, yscale=:log10, label="theoretical")
plot!(esno, symerr, marker=:circle, yscale=:log10, label="montecarlo")
