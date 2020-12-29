# This file includes modulator

export Modulator, scheme, alphabet, modulate, constellation


"""
    $TYPEDEF

Digital modulator.

# Fields 

    $TYPEDFIELDS
"""
struct Modulator{T<:AbstractScheme}
    "Modulation scheme"
    scheme::T
    "Modulation pulse energy"
    Ep::Float64 
end 
Modulator(scheme) = Modulator(scheme, 1.)

show(io::IO, modulator::Modulator) = print(io, "Modulator(scheme:$(modulator.scheme), E:$(modulator.Ep))")

# Modulation
(modulator::Modulator{<:Union{PAM, FSK}})(stream) = alphabet(modulator)[stream]
(modulator::Modulator{<:Union{ASK, PSK, QAM}})(stream) = alphabet(modulator)[stream]


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

"""
    $SIGNATURES

Returns the alphabet of the modulator
"""
alphabet(modulator::Modulator{<:Union{PAM, FSK}}) = alphabet(modulator.scheme) * sqrt(modulator.Ep)
alphabet(modulator::Modulator{<:Union{ASK, PSK, QAM}}) = alphabet(modulator.scheme) * sqrt(modulator.Ep / 2)

