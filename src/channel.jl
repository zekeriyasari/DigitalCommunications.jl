# This file includes channel objects. 

export AWGNChannel 

"""
    $TYPEDEF

Additive white Gaussian noise channel. 

# Fields 

    $TYPEDFIELDS
"""
mutable struct AWGNChannel
    "Value of the noise mode(may be `SNR`, `EsNo`, `EbNo` in dB"
    esno::Float64 
end 
AWGNChannel() = AWGNChannel(1.) 

function (channel::AWGNChannel)(tx)
    # Note: The channel is a vector channel. Elements of `tx` are the vectors `sm` that represents the signal waveform
    # transmitted for the symbol `m`. The channel corrupts the signal by adding additive white Gaussian noise `n` whose
    # elements `n1, n2, ..., nN` are the projections of the bandpass continous time noise process. The power spectral
    # density of the noise process is assumed to be N0 / 2. Thus, the variances of the random variables with variance N0
    # / 2.
    K = length(tx)          # Number of symbols transmitted 
    N = length(tx[1])       # Constellation size of modulation 
    Es = sum(energy.(tx)) / K     # Average energy per symbol 
    σ = sqrt(Es / dbtoval(channel.esno) / 2)  # Standard deviation of projections random variables. 
    n = collect(eachrow(σ * randn(K, N)))
    tx + n
end

energy(s) = sum(s.^2)
