# This file includes an example simulation of BPSK system using a threshold detector and 
# using DigitalCommunications blocks. MonteCarlo runs are compared with theoretical values. 

using Plots 
using DigitalCommunications

# `runsim_binary` function employs a simple threshold detecter.
function runsim_binary(γb, M, nbits)
    σ = √(1 / (2 * γb))
    b = rand(Bool, nbits)
    m = 1 .- 2 * b
    n = σ * randn(nbits)
    r = m + n
    extbit = r .< 0
    extber = sum(extbit .!= b) / nbits
end

# `runsim_mary` function employs DigitalCommunications blocks. 
function runsim_mary(γb, M, nbits)
    k = Int(log2(M))
    σ = √(1 / (2 * k * γb))

    # Consruct communication system blocks 
    gen = Generator(nbits)
    modulator = Modulator(PSK(), M)
    channel = AWGNChannel(0, σ)
    detector = MLDetector(signalset(modulator))

    # Run communciation system 
    extbits = gen.bits |> modulator |> channel |> detector
    sum(gen.bits .!= extbits) / nbits 
end

# Simulation parameters 
k = 1
M = 2^k
nbits = 1_000_000 
γb = -4 : 1 : 10

# Run simulations 
simtheoretical =  berpsk.(dbtosnr.(γb), M) / k
simbinary = runsim_binary.(dbtosnr.(γb), M, nbits)
simmary = runsim_mary.(dbtosnr.(γb), M, nbits)

# Plot results 
plotlyjs()
scale = :log10
scatter(γb, simtheoretical, yscale=scale, ylims=(1e-6, 1e-1), marker=(2,), label="theoretical")
scatter!(γb, simbinary, yscale=scale, marker=(2,), label="binary")
scatter!(γb, simmary, yscale=scale, marker=(2,), label="mary")
