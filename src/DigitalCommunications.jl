#= 
    A module for digital communications 
=# 
module DigitalCommunications

using DocStringExtensions

export 
    Generator, 
    GrayCoding, 
    ASK, PSK, QAM, FSK, Modulator, scheme, alphabet, symbolsize, mapstream, modulate, 
    AWGNChannel, ebno

##### Stream Generator 
"""
    $TYPEDEF

A stream generator 

# Fields 

    $TYPEDFIELDS
"""
struct Generator 
    bits::Vector{Bool}
    Generator(nbits::Int) = new(rand(Bool, nbits))
end 

##### Gray Coding 

abstract type AbstractCoding end

""" 
    $TYPEDEF 

Gray coding. 

!!! note 
    In Gray coding just a single bit changes between adjacent symbols

# Fields

    $TYPEDFIELDS
"""
struct GrayCoding <: AbstractCoding 
    pairs::Dict
end 

"""
    GrayCoding(k)

Constructs a `GrayCoding` with symbol size `k`. 

# Example 
```julia 
julia> gc = GrayCoding(2) 
GrayCoding(Dict([0, 1] => 2,[1, 1] => 3,[0, 0] => 1,[1, 0] => 4))
```
"""
function GrayCoding(k::Int)
    m = 0 : 1 << k - 1
    codes = m .⊻ (m .>> 1)
    codes = reverse.(digits.(codes, base=2, pad=k))
    GrayCoding(Dict(zip(codes, m .+ 1)))
end

##### Modulator 
"""
    $TYPEDEF

Abstract type for modulation schemes such as PAM, ASK, PSK, FSK, QAM, etc. 
"""
abstract type AbstractScheme end

"""
    $TYPEDEF

Pulse Amplitude Modulation. The mapping rule is 
```math 
    s_m = A_m p(t) \\quad m = 1, \\ldots, M
```
"""
struct PAM <: AbstractScheme end 

"""
    $TYPEDEF

Amplitude Shift Keying. The mapping rule is 
```math 
    s_m = A_m g(t) cos(w_c t)  \\quad m = 1, \\ldots, M
```
where ``A_m = 2m - 1 - M`` 
"""
struct ASK <: AbstractScheme end 

"""
    $TYPEDEF

Phase Shift Keying. The mapping rule is 
```math 
    s_m = g(t) cos(w_c t - \\theta_m) \\quad m = 1, \\ldots, M
```
where ``\\theta_m = \\dfrac{2\\pi(m - 1)}{M}``.
"""
struct PSK <: AbstractScheme end 

"""
    $TYPEDEF


Frequency Shift Keying. The mapping rule is 
```math 
    s_m = A cos(w_c t + w_m t) \\quad m = 1, \\lots, M
```
where ``w_m = m \\Delta f``
"""
struct FSK <: AbstractScheme end 

"""
    $TYPEDEF

Quadrature Amplitude Modulation. The mapping rule is 
```math 
    s_m = A_{mi} g(t) cos(w_c t) - A_{mi} g(t) sin(w_c t) 
```
where the amplitudes ``A_{mi}, A_{mq} \\in \\{ \\pm 1, \\pm 3, \\ldots, \\pm (M - 1) \\}`` 
"""
struct QAM <: AbstractScheme end 

"""
    $TYPEDEF

Baseband digital modulator.

# Fields 
    $TYPEDFIELDS
"""
struct Modulator{ST<:AbstractScheme, CT<:AbstractCoding}
    "Modulation scheme"
    scheme::ST
    "Constellation size"
    M::Int 
    "Coding to map stream to code words"
    coding::CT
end 
Modulator(scheme::ST, M::Int) where {ST} = Modulator(scheme, M, GrayCoding(Int(log2(M))))

"""
    $SIGNATURES

Returns scheme of the modulation `mod`. 
"""
scheme(mod::Modulator{ST, CT}) where {ST, CT} = ST

"""
    $SIGNATURES

Returns the symbols size of the modulator `mod`.
"""
symbolsize(mod::Modulator) = Int(log2(mod.M))

"""
    $SIGNATURES

Returns the alphabet of the modulator `mod`.

# Example
```julia 
julia> modulator = Modulator(PSK(), 4)  # 4-PSK modulator 
Modulator{PSK,GrayCoding}(PSK(), 4, GrayCoding(Dict([0, 1] => 2,[1, 1] => 3,[0, 0] => 1,[1, 0] => 4)))

julia> alphabet(mod)
Dict{Array{Int64,1},Int64} with 4 entries:
  [0, 1] => 2
  [1, 1] => 3
  [0, 0] => 1
  [1, 0] => 4
```
"""
alphabet(mod::Modulator) = mod.coding.pairs


"""
    $SIGNATURES

Maps the bit stream into different levels according to the `coding` of the modulator `mod`.

# Example 
```julia 
julia> modulator = Modulator(PSK(), 4)  # 4-PSK modulator 
Modulator{PSK,GrayCoding}(PSK(), 4, GrayCoding(Dict([0, 1] => 2,[1, 1] => 3,[0, 0] => 1,[1, 0] => 4)))

julia> bits = rand(Bool, 10)
10-element Array{Bool,1}:
 0
 0
 0
 1
 1
 0
 1
 0
 0
 0

julia> mapstream(modulator, bits)
5-element Array{Int64,1}:
 1
 2
 4
 4
 1
```
"""
function mapstream(mod::Modulator, stream) 
    # Construct codewords
    k = symbolsize(mod)
    codewords = collect(Iterators.partition(stream, k))

    # Map codewords into levels 
    alph = mod.coding.pairs
    map(codewords) do codeword 
        alph[codeword]
    end
end 

# Modulator is callable. When called with a bit stream, 
# it modulates the bit stream into message symbols. 
function (mod::Modulator)(stream) 
    levels = mapstream(mod, stream)
    map(levels) do m 
        modulate(mod, m)
    end
end

modulate(mod::Modulator{ASK, CT}, m) where CT = [2m - 1 - mod.M]
modulate(mod::Modulator{PSK, CT}, m) where CT = (θ = 2π / mod.M * (m - 1); [cos(θ), sin(θ)])

##### Channel 
"""
    $TYPEDEF

Additive white Gaussian noise channel. 

# Fields 

    $TYPEDFIELDS
"""
struct AWGNChannel 
    "Mean"
    m::Float64 
    "Standard deviation"
    σ::Float64 
end 

# Channel is callable. When called with the message signal, 
# it corrupts the message signals by adding noise. 
function (channel::AWGNChannel)(s)
    N = length(s[1])
    K = length(s)
    n = channel.σ  * [randn(N) for i in 1 : K] 
    s + n 
end

"""
    $SIGNATURES

Converts `γ` from `dB` value to its real value.

# Example 
```julia 
julia> ebno(2)  # γ = 2 dB
1.5848931924611136
```
"""
ebno(γ) = 10^(γ / 10)

end # module 
