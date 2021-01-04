# This file includes baseband modulator

export Modulator, scheme, alphabet, modulate, constellation, basis, iswaveform

"""
    $TYPEDEF

Baseband digital modulator.

!!! note `tsample` determines the type of modulation. If `tsample` is `NaN`, the modulator transmits the vectors whose
    elements are the coefficients of the expansion of the symbol waveform over the orthogonal basis. Otherwise, the
    modulator trasmits the symbol waveform sampled by `tsample`. 

# Fields 

    $TYPEDFIELDS
"""
struct Modulator{T<:AbstractScheme, S<:AbstractPulse} 
    "Modulation scheme"
    scheme::T
    "Modulation pulse energy"
    pulse::S 
    "Sampling time."
    tsample::Float64
end 
Modulator(scheme) = Modulator(scheme, RectangularPulse(), NaN)

show(io::IO, modulator::Modulator) = print(io, 
    "Modulator(scheme:$(modulator.scheme), pulse:$(modulator.pulse))")

"""
    $SIGNATURES

Returns true if modulator a waveform modulator 
"""
iswaveform(modulator::Modulator) = modulator.tsample !== NaN 

# Modulation
(modulator::Modulator)(ms) = iswaveform(modulator) ? wavemodulate(modulator, ms) : vecmodulate(modulator, ms)

function vecmodulate(modulator::Modulator{T,S}, stream) where {T, S}
    # Note: In this case, `modulator` maps each element of `stream` to a vector whose elements(possibly complex) are the
    # coefficients of the expansion of symbol waveform over the basis of the modulator.
    scheme = modulator.scheme
    pulse = modulator.pulse 
    Eg = energy(pulse)
    T <: FSK ? alphabet(scheme)[stream] * sqrt(2 * Eg) : alphabet(scheme)[stream] * sqrt(Eg)
end 

function wavemodulate(modulator::Modulator{T, S}, symbols) where {T, S}
    # Note: In this case, `modulator` maps each element of `stream` to a waveform that is spanned by the basis of the
    # modulator.
    pulse = modulator.pulse 
    ts = modulator.tsample 
    tp = pulse.duration
    t = 0 : ts : tp - ts
    basisvals = map(base -> base.(t), basis(modulator)) # Precomputation of the values of the basis functions 
    si = map(symbol -> sum(alphabet(modulator.scheme)[symbol] .* basisvals), symbols)
    Eg = energy(pulse)
    T <: FSK ? si * sqrt(2 * Eg)  : si * sqrt(Eg)
end

"""
    $SIGNATURES

Returns basis `modulator` 
"""
function basis(modulator::Modulator{T, S}) where {T, S}
    iswaveform(modulator) || error("Expected waveform modulator, got a vector modulator")
    pulse = modulator.pulse 
    Eg = energy(pulse) 
    M = constelsize(modulator.scheme)
    if T <: FSK 
        # Multidimensional signalling 
        Δf = 1 / pulse.duration  # Minimum frequency sepeartion for orthogonality of the basis. 
        map(m -> (t -> pulse(t) * exp(1im * 2π * m * Δf * t)), 1 : M)
    else 
        # Two dimensional signalling 
        [t -> pulse(t) / sqrt(Eg)]
    end 
end 

"""
    $SIGNATURES

Returns scheme of the modulation `modulator`. 
"""
scheme(modulator::Modulator) = modulator.scheme

"""
    $SIGNATURES

Returns the constellation size of `modulator`
"""
constelsize(modulator::Modulator) = constelsize(modulator.scheme)

