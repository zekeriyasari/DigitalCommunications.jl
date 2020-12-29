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

"""
    $SIGNATURES

Returns scheme of the modulation `modulator`. 
"""
scheme(modulator::Modulator) = modulator.scheme

"""
    $SIGNATURES

Returns the symbols size of the modulator `modulator`.
"""
constelsize(modulator::Modulator) = constelsize(modulator.scheme)

"""
    $SIGNATURES

Returns the alphabet of the modulator `modulator`.

# Example
```julia 
julia> modulator = Modulator(PSK(4))
Modulator(scheme:4-PSK, coding:GrayCoding(M:4))

julia> alphabet(modulator)
4-element Array{Array{Float64,1},1}:
 [1.0, 0.0]
 [6.123233995736766e-17, 1.0]
 [-1.0, 1.2246467991473532e-16]
 [-1.8369701987210297e-16, -1.0]
```
"""
alphabet(modulator::Modulator) = alphabet(modulator.scheme)


# Modulation...
(modulator::Modulator{<:Union{PAM, FSK}})(stream) = alphabet(modulator)[stream] * sqrt(modulator.Ep)
(modulator::Modulator{<:Union{ASK, PSK, QAM}})(stream) = alphabet(modulator)[stream] * sqrt(modulator.Ep / 2)

# TODO: #27 The argument to `constellation` shoul be `scheme` instead of `modulator`. 
"""
    $SIGNATURES 

Plots the constellation diagram of the `modulator`.
"""
function constellation(modulator::Modulator{ST}) where {ST} 
    s = alphabet(modulator) 
    if ST <: ASK || ST <: PAM
        ymax = 1
        plt = scatter(vcat(s...), zeros(length(s)), ylims=(-ymax, ymax))
        foreach(item -> annotate!(item[2][1],  0.1, item[1]), enumerate(s)) 
    elseif ST <: PSK || ST <: QAM
        ymax = maximum(norm.(s)) * 1.25
        plt = scatter(getindex.(s, 1), getindex.(s, 2), marker=:circle, ylims=(-ymax, ymax))
        foreach(item -> annotate!(item[2][1] * 0.9, item[2][2] * 0.9, item[1]), enumerate(s)) 
    else 
        error("Unknown modulation scheme. Expected `PAM, PSK, QAM, FSK`, got $ST instead.")
    end
    plt
end
