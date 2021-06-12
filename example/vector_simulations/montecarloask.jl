# This file includes the MonteCarlo simulation of ASK modulation scheme and compares 
# the numerical results with the theoretical results. 

using DigitalCommunications 
using Plots 

# Simulation parameters 
theme(:default)
plt = plot(legend=:bottomleft) 
for k in 1 : 3
    M = 2^k 
    nsymbols = Int(1e6) 
    nbits = k * nsymbols
    ebno = collect(0 : 10)    
    esno = ebno .+ 10 * log10(k)

    # Communcation system components  
    gen = SymbolGenerator(nsymbols, M) 
    modulator = Modulator(ASK(M))
    channel = AWGNChannel() 
    detector = Detector(modulator(1:M))

    # Monte Carlo simulation 
    message = gen.symbols
    symerr = zeros(length(esno))
    for i in 1 : length(symerr)
        channel.esno = esno[i]  # Update channel snr
        mbar = message |> modulator |> channel |> detector  # Extracted message signal 
        symerr[i] = sum(mbar .!= message) / length(message)  # Symbol error rate 
    end

    plot!(ebno, berask.(ebno, M), yscale=:log10, lw=0.5, 
        markershape=:auto, color=:black, gridalpha=0.9, minorgrid=true, minorgridalpha=0.5, label="$M-ASK-theoretical")
    plot!(ebno, symerr,  yscale=:log10, lw=0.5, 
        markershape=:auto, color=:black, gridalpha=0.9, minorgrid=true, minorgridalpha=0.5, label="$M-ASK-montecarlo")
end
display(plt) 