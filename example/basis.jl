# This file includes an example script to plot the basis functions of PSK modulator.

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
gen = BitGenerator(nbits) 
modulator = Modulator(FSK(M))

# Plot the basis of the modulator 
t = 0 : modulator.tsample : modulator.pulse.duration
plt = plot(layout=(constelsize(modulator.scheme),1))
for (i, base) in enumerate(basis(modulator))
    plot!(t, base.(t), subplot=i)
end 
display(plt)
