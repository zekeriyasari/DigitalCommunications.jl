# This file includes the simulation of a PSK modulation 

using Plots 
using DigitalCommunications

# Settings 
snrrange = 1 : 24
ber = zeros(length(snrrange))
for (i, γb) in enumerate(snrrange)
    k = 2
    M = 2^k
    l = 1_000_000 
    nbits = k * l
    σ = √(1 / (2 * ebno(γb)))

    # Consruct communication system blocks 
    gen = Generator(nbits)
    modulator = Modulator(PSK(), M)
    channel = AWGNChannel(0, σ)
    detector = MLDetector(signalset(modulator))

    # Run communciation system 
    extbits = gen.bits |> modulator |> channel |> detector
    ber[k] = sum(gen.bits .!= extbits)
    @info "Done $i"
end
@show ber
# plot(snrrange, ber, yscale=:log10)

