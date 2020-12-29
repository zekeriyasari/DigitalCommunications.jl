# This file includes the MonteCarlo simulation of ASK modulation scheme and compares 
# the numerical results with the theoretical results. 

using DigitalCommunications 
using Plots 

# Simulation parameters 
k = 2
M = 2^k 
nsymbols = Int(1e6) 
nbits = k * nsymbols
ebno = collect(0 : 10)          # Snr per bit 
esno = ebno .+ 10 * log10(k)    # Snr ber symbol  

# Communcation system components  
gen = Generator(nbits) 
modulator = BandpassModulator(PSK(M))

# Plot the basis of the modulator 
t = 0 : modulator.tsample / 100 : modulator.pulse.duration
plt = plot(layout=(constelsize(modulator.scheme),1))
for (i, base) in enumerate(basis(modulator))
    plot!(t[1:100], base.(t)[1:100], subplot=i)
end 
display(plt)
