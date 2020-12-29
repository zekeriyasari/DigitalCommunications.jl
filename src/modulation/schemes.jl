# This file includes digital modulation schemes. 

export ASK, PSK, QAM, FSK, PAM, constelsize


abstract type AbstractScheme end


for name in [:PAM, :ASK, :PSK, :QAM, :FSK]
    @eval begin 
        struct $name <: AbstractScheme 
            "Constellation size"
            M::Int
            function $name(M::Int) 
                ispow2(M) || throw(ArgumentError("Expected `M` to be power of 2, got $M instead"))
                new(M)
            end
        end 
    end 
end

"""
    $SIGNATURES

Returns the alphabet of `scheme`.

# Example 
```julia 
julia> scheme = PSK(4)
4-PSK

julia> alphabet(scheme)
4-element Array{Array{Float64,1},1}:
 [1.0, 0.0]
 [6.123233995736766e-17, 1.0]
 [-1.0, 1.2246467991473532e-16]
 [-1.8369701987210297e-16, -1.0]
```
"""
function alphabet end 

"""
    $SIGNATURES

Returns ``[2m - 1 - M], \\; m = 1, \\ldots, M`` where `M` is constellation size of `scheme`.
"""
function alphabet(scheme::Union{PAM, ASK}) 
    M = scheme.M
    [[2m - 1 - M] for m in 1 : M]
end 

""" 
    $SIGNATURES

Returns ``[cos(\\theta_m), sin(\\theta_m)], \\; m = 1, \\ldots, M`` where ``\\theta_m = \\dfrac{2\\pi(m - 1)}{M}`` and
`M` is the constellation size of the `scheme`.
"""
function alphabet(scheme::PSK)
    M = scheme.M
    [[cos(θ), sin(θ)] for θ in 2π * (0 : M - 1) / M] 
end 

""" 
    $SIGNATURES

Returns ``[2m - 1 - M, 2n - 1 - M], \\; m, n = 1, \\ldots, M`` where `M` is the constellation size of the `scheme`.
"""
function alphabet(scheme::QAM)
    M = Int(sqrt(scheme.M))
    Mrange = -(M - 1) : 2 : (M - 1)
    vec([[i, j] for i in Mrange, j in Mrange])
end 

""" 
    $SIGNATURES

Returns ``[0, 0, \\ldots, 1, 0, \\ldots, 0], \\; m = 1, \\ldots, M`` where the index of the nonzero element is ``m`` and
`M` is the constellation size of the `scheme`.
"""
function alphabet(scheme::FSK)
    M = scheme.M
    map(i -> setindex!(zeros(M), 1, i), 1 : M) 
end 

show(io::IO, scheme::T) where T <: AbstractScheme = print(io, "$(scheme.M)-$(T.name)")

"""
    $SIGNATURES

Returns the symbols size of `scheme`.

# Example 
```julia 
julia> sch = PSK(4);

julia> constelsize(sch)
4
```
"""
constelsize(scheme::AbstractScheme) = scheme.M

# TODO: #27 The argument to `constellation` shoul be `scheme` instead of `modulator`. 
"""
    $SIGNATURES 

Plots the constellation diagram of the `modulator`.
"""
function constellation(scheme::T) where {T<:AbstractScheme} 
    s = alphabet(scheme) 
    if T <: ASK || T <: PAM
        ymax = 1
        plt = scatter(vcat(s...), zeros(length(s)), ylims=(-ymax, ymax))
        foreach(item -> annotate!(item[2][1],  0.1, item[1]), enumerate(s)) 
    elseif T <: PSK || T <: QAM
        ymax = maximum(norm.(s)) * 1.25
        plt = scatter(getindex.(s, 1), getindex.(s, 2), marker=:circle, ylims=(-ymax, ymax))
        foreach(item -> annotate!(item[2][1] * 0.9, item[2][2] * 0.9, item[1]), enumerate(s)) 
    else 
        error("Unknown modulation scheme. Expected `PAM, ASK, PSK, QAM`, got $T instead.")
    end
    plt
end
