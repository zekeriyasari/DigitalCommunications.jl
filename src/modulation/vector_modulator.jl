# This file includes baseband modulator

export VectorModulator, scheme, alphabet, modulate, constellation


abstract type AbstractModulator end


"""
    $TYPEDEF

Digital modulator.

# Fields 

    $TYPEDFIELDS
"""
struct VectorModulator{T<:AbstractScheme} <: AbstractModulator
    "Modulation scheme"
    scheme::T
    "Modulation pulse energy"
    Ep::Float64 
end 
VectorModulator(scheme) = VectorModulator(scheme, 1.)

show(io::IO, modulator::VectorModulator) = print(io, 
    "VectorModulator(scheme:$(modulator.scheme), E:$(modulator.Ep))")

# Modulation
(modltr::VectorModulator{<:Union{PAM, FSK}})(stream) = alphabet(modltr.scheme)[stream] * sqrt(modltr.Ep)
(modltr::VectorModulator{<:Union{ASK, PSK, QAM}})(stream) = alphabet(modltr.scheme)[stream] * sqrt(modltr.Ep / 2)


"""
    $SIGNATURES

Returns scheme of the modulation `modulator`. 
"""
scheme(modulator::VectorModulator) = modulator.scheme

"""
    $SIGNATURES

Returns the constellation size of `modulator`
"""
constelsize(modulator::VectorModulator) = constelsize(modulator.scheme)
