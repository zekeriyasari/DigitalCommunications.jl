# This file includes waveform AWGN channel 

export WaveformAWGNChannel

"""
    $TYPEDEF

Waveform AWGN Channel 

# Fields 
    $TYPEDFIELDS
"""
struct WaveformAWGNChannel{T} <: AbstractChannel 
    "Signal signal energy to noise power spectral density ratio"
    esno::Float64
    "Basis of modulation"
    basis::T 
    "Sampling period"
    tsample::Float64
    "Symbol duration"
    tsymbol::Float64
end 

function (channel::WaveformAWGNChannel)(stream)
    # Find projection coefficients 
    nsymbols = length(stream)
    nconstellation = length(channel.basis) 
    Es = sum(energy.(stream, channel.tsample)) / nsymbols
    σ = sqrt(Es / dbtoval(channel.esno) / 2)
    noisecoefs = collect(eachrow(σ * randn(nsymbols, nconstellation)))

    # Synthetize noise 
    t = 0 : channel.tsample : channel.tsymbol - channel.tsample
    waveforms = map(base -> base.(t), channel.basis)
    noise = map(ni -> sum(ni .* waveforms), noisecoefs)

    # Corrupt input stream
    stream + noise 
end