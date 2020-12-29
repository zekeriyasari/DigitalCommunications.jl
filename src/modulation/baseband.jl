# This file includes baseband modulator

export BasebandModulator, scheme, alphabet, modulate, constellation


abstract type AbstractModulator end


"""
    $TYPEDEF

Digital modulator.

# Fields 

    $TYPEDFIELDS
"""
struct BasebandModulator{T<:AbstractScheme} <: AbstractModulator
    "Modulation scheme"
    scheme::T
    "Modulation pulse energy"
    Ep::Float64 
end 
BasebandModulator(scheme) = BasebandModulator(scheme, 1.)

show(io::IO, modulator::BasebandModulator) = print(io, 
    "BasebandModulator(scheme:$(modulator.scheme), E:$(modulator.Ep))")

# Modulation
(modltr::BasebandModulator{<:Union{PAM, FSK}})(stream) = alphabet(modltr.scheme)[stream] * sqrt(modltr.Ep)
(modltr::BasebandModulator{<:Union{ASK, PSK, QAM}})(stream) = alphabet(modltr.scheme)[stream] * sqrt(modltr.Ep / 2)


"""
    $SIGNATURES

Returns scheme of the modulation `modulator`. 
"""
scheme(modulator::BasebandModulator) = modulator.scheme

"""
    $SIGNATURES

Returns the constellation size of `modulator`
"""
constelsize(modulator::BasebandModulator) = constelsize(modulator.scheme)
