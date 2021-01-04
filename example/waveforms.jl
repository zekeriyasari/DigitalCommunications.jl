# This file includes an example script to plot the basis functions of PSK modulator.

using DigitalCommunications 
using Plots; plotlyjs()

# Simulation parameters 
k = 2
M = 2^k 
nsymbols = 2
nbits = k * nsymbols
ebno = collect(0 : 10)          # Snr per bit 
esno = ebno .+ 10 * log10(k)    # Snr ber symbol  

# Communcation system components  
gen = BitGenerator(nbits) 
coding = GrayCoding(M)
modulator = Modulator(PSK(M))
channel = WaveformAWGNChannel(esno[1], basis(modulator), modulator.tsample, modulator.pulse.duration)

# Simulate the system 
@run gen.bits |> coding |> modulator
tx = gen.bits |> coding |> modulator
rx = tx |> channel

# Plots
sps = Int(modulator.pulse.duration / modulator.tsample)
t = collect(Iterators.partition(0 : modulator.tsample : modulator.pulse.duration * nsymbols, sps))
plt = plot()
for (ti, txi, rxi) in zip(t, tx, rx)
    plot!(ti, txi) 
    plot!(ti, rxi) 
end 
display(plt)
