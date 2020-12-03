# This file includes an example simulation of BPSK system using a threshold detector and 
# using DigitalCommunications blocks. MonteCarlo runs are compared with theoretical values. 

using Plots 
using DigitalCommunications

# `runsim_mary` function employs DigitalCommunications blocks. 
function runsim_mary(γb, M, nbits)
    k = Int(log2(M))
    σ = √(1 / (2 * k * γb))

    # Construct communication system blocks 
    gen = Generator(nbits)
    modulator = Modulator(ASK(), M)
    channel = AWGNChannel(0, σ)
    detector = MLDetector(signalset(modulator))

    # Run communciation system
    extsymbols = gen.bits |> modulator |> channel |> detector
    sentsymbols = collect(Iterators.partition(gen.bits, k))
    sum(extsymbols .!= sentsymbols) / length(sentsymbols)
end

# Simulation parameters 
k = 1
M = 2^k
nsymbols = Int(1e4)
nbits = k * nsymbols
γb = -4 : 1 : 10

# Run simulations 
simtheoretical =  berask.(dbtosnr.(γb), M)
simmary = runsim_mary.(dbtosnr.(γb), M, nbits)

# Plot results 
plotlyjs()
scale = :log10
ms = 2
scatter(γb, simtheoretical, yscale=scale, ylims=(1e-3, 1e-0), markersize=ms, label="theoretical")
scatter!(γb, simmary, yscale=scale, markersize=ms, label="mary")
