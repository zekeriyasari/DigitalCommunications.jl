using DigitalCommunications 
using Plots; plotlyjs()

# Plot theoreitcal ber simulation. 
γb = collect(0 : 2 : 12) 
pb = berpsk.(γb, 2)
plot(γb, pb, yscale=:log10, marker=(:circle, 2), label="theoretical")

# Monte Carlo simulation 
k = 1 
M = 2^k
nbits = 10 

# Blocks 
gen = Generator(nbits) 
modulator = Modulator(ASK(), 8)
constellation(modulator)
