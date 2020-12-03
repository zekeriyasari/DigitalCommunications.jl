# This file includes the simulation of a PSK modulation 

using Plots 
using DigitalCommunications

γb = 6
k = 2
M = 2^k 
bertheo = berask(dbtosnr(γb), M)

nsymbols = Int(1e6)
nbits = k * nsymbols
σ = √(1 / (2 * k * dbtosnr(γb)))

# Construct communication system blocks 
gen = Generator(nbits)
modulator = Modulator(ASK(), M)
channel = AWGNChannel(0, σ)
detector = MLDetector(signalset(modulator))

# Run communciation system 
extsymbols = gen.bits |> modulator |> channel |> detector
sentsymbols = collect(Iterators.partition(gen.bits, k))
bersim = sum(extsymbols .!= sentsymbols) / length(sentsymbols) 
@show bersim, bertheo
@show log10(bersim), log10(bertheo)
nothing