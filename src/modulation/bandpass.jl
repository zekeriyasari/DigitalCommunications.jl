# This file includes bandpass modulators.

export BandpassModulator, basis

"""
    $TYPEDEF

# Fields 
    $TYPEDFIELDS

Bandpass modulator
"""
struct BandpassModulator{T<:AbstractScheme, S<:AbstractPulse} <: AbstractModulator
    "Modulation scheme"
    scheme::T 
    "Modulation basis"
    pulse::S 
    "Carrier frequency in Hz"
    fcarrier::Float64
    "Sample duration"
    tsample::Float64
end
BandpassModulator(scheme, pulse=Rectangular()) = 
    BandpassModulator(scheme, pulse, bandwidth(pulse) * 100, pulse.duration/100)

function basis(modulator::BandpassModulator{PAM, S}) where {S}
    pulse = modulator.pulse 
    α = 1 / sqrt(energy(pulse))
    [t -> α * pulse(t)]
end

function basis(modulator::BandpassModulator{ASK, S}) where {S} 
    pulse = modulator.pulse 
    α =  sqrt(2 / energy(pulse))
    [t ->  α * pulse(t) * cos(2π * modulator.fcarrier * t)]
end

function basis(modulator::BandpassModulator{<:Union{PSK, QAM}, S}) where {S} 
    pulse = modulator.pulse 
    α =  sqrt(2 / energy(pulse))
    [
        t ->  α * pulse(t) * cos(2π * modulator.fcarrier * t), 
        t ->  -α * pulse(t) * sin(2π * modulator.fcarrier * t)
    ]
end

function basis(modulator::BandpassModulator{FSK, S}) where {S} 
    pulse = modulator.pulse 
    Δf = 1 / (2 * pulse.duration)  # The minimum frequency seperation for orthogonality of base signals.
    N = constelsize(modulator)
    α =  1 / sqrt(energy(pulse))
    map(m -> (t ->  α * pulse(t) * cos(2π * (modulator.fcarrier + m * Δf) * t)), 1 : N) 
end

function (modulator::BandpassModulator{<:Union{PAM, FSK}, S})(stream) where {S}
    t = 0 : modulator.tsample : modulator.tsymbol
    α = sqrt(energy(modulator.pulse))
    sum(α * alphabet(modulator)[stream] .* map(base -> base.(t), modulator.basis))
end

function (modulator::BandpassModulator{<:Union{PSK, ASK, QAM}, S})(stream) where {S}
    t = 0 : modulator.tsample : modulator.tsymbol
    α = sqrt(energy(modulator.pulse) / 2)
    sum(α * alphabet(modulator)[stream] .* map(base -> base.(t), modulator.basis))
end

