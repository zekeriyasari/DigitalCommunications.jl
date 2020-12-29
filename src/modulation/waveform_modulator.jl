# This file includes bandpass modulators.

export WaveformModulator, basis

"""
    $TYPEDEF

# Fields 
    $TYPEDFIELDS

Bandpass modulator
"""
struct WaveformModulator{T<:AbstractScheme, S<:AbstractPulse} <: AbstractModulator
    "Modulation scheme"
    scheme::T 
    "Modulation basis"
    pulse::S 
    "Carrier frequency in Hz"
    fcarrier::Float64
    "Sample duration"
    tsample::Float64
end
function WaveformModulator(scheme, pulse=Rectangular())
    fcarrier = bandwidth(pulse) * 100
    tsample = 1 / (100 * fcarrier)
    WaveformModulator(scheme, pulse, fcarrier, tsample)
end 

function basis(modulator::WaveformModulator{PAM, S}) where {S}
    pulse = modulator.pulse 
    α = 1 / sqrt(energy(pulse))
    [t -> α * pulse(t)]
end

function basis(modulator::WaveformModulator{ASK, S}) where {S} 
    pulse = modulator.pulse 
    α =  sqrt(2 / energy(pulse))
    [t ->  α * pulse(t) * cos(2π * modulator.fcarrier * t)]
end

function basis(modulator::WaveformModulator{<:Union{PSK, QAM}, S}) where {S} 
    pulse = modulator.pulse 
    α =  sqrt(2 / energy(pulse))
    [
        t ->  α * pulse(t) * cos(2π * modulator.fcarrier * t), 
        t ->  -α * pulse(t) * sin(2π * modulator.fcarrier * t)
    ]
end

function basis(modulator::WaveformModulator{FSK, S}) where {S} 
    pulse = modulator.pulse 
    # Note: For the orthogonality of base signals, minimum frequency seperation betwen the base signals Δf 
    # is 1 / (2T) where T is the pulse (symbol transmission) duration. In our case, the frequencu seperation between 
    # the base signals is 10 / (2T). 
    Δf = 10 * 1 / (2 * pulse.duration)  
    N = constelsize(modulator.scheme)
    α =  1 / sqrt(energy(pulse))
    map(m -> (t ->  α * pulse(t) * cos(2π * (modulator.fcarrier + m * Δf) * t)), 1 : N) 
end

function (modulator::WaveformModulator{<:Union{PAM, FSK}, S})(stream) where {S}
    t = 0 : modulator.tsample : modulator.tsymbol
    α = sqrt(energy(modulator.pulse))
    sum(α * alphabet(modulator)[stream] .* map(base -> base.(t), modulator.basis))
end

function (modulator::WaveformModulator{<:Union{PSK, ASK, QAM}, S})(stream) where {S}
    t = 0 : modulator.tsample : modulator.pulse.duration - modulator.tsample
    α = sqrt(energy(modulator.pulse) / 2)
    s = alphabet(modulator.scheme)[stream]
    b = map(base -> base.(t), basis(modulator))
    map(si -> sum(si .* b), s)
end

